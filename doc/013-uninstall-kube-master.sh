#!/bin/bash

set -x

RED='\033[0;31m'
NC='\033[0m'

# Reset kubeadm
echo -e "${RED}Reset kubeadm${NC}"
kubeadm reset

# Stop kubelet and docker
echo -e "${RED}Stop kubelet and docker${NC}"
systemctl stop kubelet
systemctl stop docker

# Remove cni, kubelet, flannel, cni, Kubernetes and etcd
echo -e "${RED}Remove cni, kubelet, flannel, cni, Kubernetes and etcd${NC}"
rm -rf /var/lib/cni/
rm -rf /var/lib/kubelet/*
rm -rf /run/flannel
rm -rf /etc/cni/
rm -rf /etc/kubernetes
rm -rf /var/lib/etcd/

# Delete IP link for CNI and flannel
echo -e "${RED}Delete IP link for CNI and flannel${NC}"
ip link delete cni0
ip link delete flannel.1

# Remove packages of kubelet, kubectl and kubeadm
echo -e "${RED}Remove packages of kubelet, kubectl and kubeadm${NC}"
yum remove -y kubelet
yum remove -y kubectl
yum remove -y kubeadm

# Restart docker
echo -e "${RED}Restart docker${NC}"
systemctl start docker
