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
KUBERNETES_VERSION="1.24.0-00"

sudo apt update -y #Actualizamos repositorios

sudo apt -y install curl apt-transport-https vim git curl wget #Instalamos paquetes necesarios

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - #Importamos key
#sudo cp /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list #Añadimos repositorios de k8s

sudo apt update #Actualizamos para que coja los repositorios nuevos
sudo apt -y install kubelet=$KUBERNETES_VERSION kubeadm=$KUBERNETES_VERSION kubectl=$KUBERNETES_VERSION #Instalamos los paquetes de k8s
sudo apt-mark hold kubelet kubeadm kubectl #bloqueamos la version de los paquetes

#Instalamos CRI-O https://github.com/cri-o/cri-o/blob/main/tutorials/install-distro.md

export OS_VERSION=xUbuntu_20.04
export CRIO_VERSION=1.27

curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS_VERSION/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS_VERSION/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS_VERSION/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS_VERSION/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

sudo apt update
sudo apt-get install -y cri-o cri-o-runc

# Update CRI-O CIDR subnet

#sudo sed -i 's/10.85.0.0/192.168.0.0/g' /etc/cni/net.d/100-crio-bridge.conf
#sudo sed -i 's/10.85.0.0/192.168.0.0/g' /etc/cni/net.d/100-crio-bridge.conflist

# Start and enable Service

sudo systemctl daemon-reload
sudo systemctl restart crio
sudo systemctl enable crio
sudo systemctl status crio