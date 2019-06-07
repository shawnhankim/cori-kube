#!/bin/bash

# 
# Declare Color Constant
#
source "./color.sh"

#
# Print Title
#
echo -e ""
echo -e "${BGreen}+------------------------------------------------------------------------------+${ColorOff}"
echo -e "${BGreen}|          Uninstall Kube Master & Delete NGINX Deployment for Ubuntu          |${ColorOff}"
echo -e "${BGreen}+------------------------------------------------------------------------------+${ColorOff}"

# Print commands 
#set -x

# Delete NGINX deployment
echo -e "${Green}\nDelete NGINX deployment ${ColorOff}"
kubectl delete deployment nginx
kubectl get deployments

# Reset kubeadm
echo -e "${Green}\nReset kubeadm${ColorOff}"
sudo kubeadm reset

# Stop kubelet 
echo -e "${Green}\nStop kubelet ${ColorOff}"
sudo systemctl stop kubelet

# Remove Docker containers and images
echo -e "${Green}\nRemove Docker containers and images${ColorOff}"
sudo docker rmi $(sudo docker images -q)       # Remove all of containers
sudo docker rm $(sudo docker ps -a -q)         # Remove all of images

# Stop docker 
echo -e "${Green}\nStop docker ${ColorOff}"
sudo systemctl stop docker

# Remove Docker 
echo -e "${Green}\nRemove Docker ${ColorOff}"
sudo apt remove docker docker-engine docker.io # Remove Docker

# Remove cni, kubelet, flannel, cni, Kubernetes and etcd
echo -e "${Green}\nRemove cni, kubelet, flannel, cni, Kubernetes and etcd${ColorOff}"
sudo rm -rf /var/lib/cni/
sudo rm -rf /var/lib/kubelet/*
sudo rm -rf /run/flannel
sudo rm -rf /etc/cni/
sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/etcd/

# Delete IP link for CNI and flannel
echo -e "${Green}\nDelete IP link for CNI and flannel${ColorOff}"
sudo ip link delete cni0
sudo ip link delete flannel.1

# Remove packages of kubelet, kubectl and kubeadm
echo -e "${Green}\nRemove packages of kubelet, kubectl and kubeadm${ColorOff}"
sudo apt remove -y kubelet
sudo apt remove -y kubectl
sudo apt remove -y kubeadm

#
# Print Completion Message
#
echo -e "${BGreen}+------------------------------------------------------------------------------+${ColorOff}"
echo -e "${BGreen}|        Completed Kube Master Uninstallation & Deleting NGINX Deployment      |${ColorOff}"
echo -e "${BGreen}+------------------------------------------------------------------------------+${ColorOff}"
