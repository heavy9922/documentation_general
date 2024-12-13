#!/bin/bash

# Descargar las imágenes necesarias para Kubeadm
echo "Descargando imágenes necesarias para Kubeadm..."
sudo kubeadm config images pull

# Configurar el archivo /etc/hosts
echo "Configurando el archivo /etc/hosts..."
echo "Por favor, reemplaza 'IP_OF_THE_MACHINE' con la dirección IP de esta máquina."
read -p "Introduce la dirección IP de la máquina: " MACHINE_IP
echo "${MACHINE_IP} k8scp" | sudo tee -a /etc/hosts

# Inicializar el cluster Kubernetes
echo "Inicializando el cluster Kubernetes..."
sudo kubeadm init --pod-network-cidr=172.24.0.0/16 \
  --cri-socket=unix:///run/containerd/containerd.sock \
  --upload-certs \
  --control-plane-endpoint=k8scp

# Configurar kubectl para el usuario actual
echo "Configurando kubectl para el usuario actual..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Exportar KUBECONFIG
echo "Exportando la variable de entorno KUBECONFIG..."
export KUBECONFIG=$HOME/.kube/config

# Verificar la información del cluster
echo "Verificando la información del cluster..."
kubectl cluster-info

echo "Cluster Kubernetes inicializado exitosamente."