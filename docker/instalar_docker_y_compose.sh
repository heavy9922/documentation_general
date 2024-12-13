
#!/bin/bash

# Script para instalar Docker y Docker Compose en Ubuntu 24.04

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependencias necesarias
echo "Instalando dependencias necesarias..."
sudo apt install -y ca-certificates curl gnupg

# Agregar la clave GPG oficial de Docker
echo "Agregando la clave GPG oficial de Docker..."
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Agregar el repositorio de Docker
echo "Agregando el repositorio de Docker..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar los repositorios
echo "Actualizando los repositorios..."
sudo apt update

# Instalar Docker
echo "Instalando Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verificar la instalación de Docker
echo "Verificando la instalación de Docker..."
docker --version

# Habilitar y arrancar el servicio de Docker
echo "Habilitando y arrancando el servicio de Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Agregar el usuario actual al grupo Docker
echo "Agregando el usuario actual al grupo Docker..."
sudo usermod -aG docker $USER
echo "Cierra la sesión y vuelve a iniciarla para aplicar los cambios."

# Instalar Docker Compose
echo "Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Asignar permisos de ejecución a Docker Compose
echo "Asignando permisos de ejecución a Docker Compose..."
sudo chmod +x /usr/local/bin/docker-compose

# Crear enlace simbólico para Docker Compose (opcional)
echo "Creando enlace simbólico para Docker Compose (si es necesario)..."
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || true

# Verificar la instalación de Docker Compose
echo "Verificando la instalación de Docker Compose..."
docker-compose --version

echo "Docker y Docker Compose se han instalado correctamente. ¡Disfruta!"
