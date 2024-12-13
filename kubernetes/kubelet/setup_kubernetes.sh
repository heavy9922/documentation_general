#!/bin/bash

# Actualización del sistema
echo "Actualizando el sistema..."
sudo apt-get update
sudo apt update && sudo apt upgrade -y

# Instalación de herramientas necesarias
echo "Instalando herramientas necesarias..."
sudo apt-get install -y apt-transport-https ca-certificates curl

# Configuración del repositorio de Kubernetes
echo "Configurando repositorio de Kubernetes..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Actualizar repositorios
sudo apt-get update

# Instalación de kubelet, kubeadm y kubectl
echo "Instalando kubelet, kubeadm y kubectl..."
sudo apt -y install wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Verificar las versiones instaladas
kubectl version --client && kubeadm version

# Deshabilitar Swap
echo "Deshabilitando Swap..."
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
free -h

# Configuración de red para Kubernetes
echo "Configurando parámetros de red para Kubernetes..."
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# Configuración de módulos para containerd
echo "Configurando módulos para containerd..."
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Instalación de containerd
echo "Instalando containerd..."
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Verificar estado de containerd
echo "Verificando estado de containerd..."
systemctl status containerd

# Preparar imágenes de Kubernetes
echo "Descargando imágenes necesarias para kubeadm..."
sudo kubeadm config images pull

# Fin del script
echo "Configuración de Kubernetes completada."