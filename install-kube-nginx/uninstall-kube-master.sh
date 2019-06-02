#!/bin/bash

# Declare color constant
ColorOff='\033[0m'
Black="\033[0;30m"        # Black
Red="\033[0;31m"          # Red
Green="\033[0;32m"        # Green
Yellow="\033[0;33m"       # Yellow
Blue="\033[0;34m"         # Blue
Purple="\033[0;35m"       # Purple
Cyan="\033[0;36m"         # Cyan
White="\033[0;37m"        # White

# Print commands 
set -x

# Reset kubeadm
echo -e "${Green}Reset kubeadm${ColorOff}"
kubeadm reset

# Stop kubelet and docker
echo -e "${Green}Stop kubelet and docker${ColorOff}"
systemctl stop kubelet
systemctl stop docker

# Remove cni, kubelet, flannel, cni, Kubernetes and etcd
echo -e "${Green}Remove cni, kubelet, flannel, cni, Kubernetes and etcd${ColorOff}"
rm -rf /var/lib/cni/
rm -rf /var/lib/kubelet/*
rm -rf /run/flannel
rm -rf /etc/cni/
rm -rf /etc/kubernetes
rm -rf /var/lib/etcd/

# Delete IP link for CNI and flannel
echo -e "${Green}Delete IP link for CNI and flannel${ColorOff}"
ip link delete cni0
ip link delete flannel.1

# Remove packages of kubelet, kubectl and kubeadm
echo -e "${Green}Remove packages of kubelet, kubectl and kubeadm${ColorOff}"
apt remove -y kubelet
apt remove -y kubectl
apt remove -y kubeadm

# Restart docker
echo -e "${Green}Restart docker${ColorOff}"
systemctl start docker