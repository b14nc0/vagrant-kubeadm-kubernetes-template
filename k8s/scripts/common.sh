#!/bin/bash

#Deshabilitamos swap
sudo swapoff -a #desmontamos la memoria swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab #quitamos la swap del fstab

#Configuramos modulos del sysctl
#habilitamos overlay y br_netfilter
sudo modprobe overlay 
sudo modprobe br_netfilter

# añadimos configuracion sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# recargamos sysctl
sudo sysctl --system

#Instalamos kubernetes

sudo apt update -y #Actualizamos repositorios

sudo apt -y install curl apt-transport-https vim git curl wget #Instalamos paquetes necesarios

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - #Importamos key
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list #Añadimos repositorios de k8s

sudo apt update #Actualizamos para que coja los repositorios nuevos
sudo apt -y install kubelet=1.25.0-00 kubeadm=1.25.0-00 kubectl=1.25.0-00 #Instalamos los paquetes de k8s
sudo apt-mark hold kubelet kubeadm kubectl #bloqueamos la version de los paquetes

#Instalamos CRI-O https://github.com/cri-o/cri-o/blob/main/tutorials/install-distro.md

OS=xUbuntu_20.04
VERSION=1.27

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

curl -k -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | sudo apt-key add -
curl -k -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

sudo cp /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d #fix contenedor de certificados

sudo apt-get update
sudo apt-get install -y cri-o cri-o-runc

# Update CRI-O CIDR subnet

#sudo sed -i 's/10.85.0.0/192.168.0.0/g' /etc/cni/net.d/100-crio-bridge.conf
#sudo sed -i 's/10.85.0.0/192.168.0.0/g' /etc/cni/net.d/100-crio-bridge.conflist

# Start and enable Service

sudo systemctl daemon-reload
sudo systemctl restart crio
sudo systemctl enable crio
sudo systemctl status crio