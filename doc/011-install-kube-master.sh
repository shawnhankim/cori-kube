#!/bin/bash

set -x

RED='\033[0;31m'
NC='\033[0m'

# Setting Environment at root user
echo -e "${RED}Setting Environment${NC}"
sudo echo 1 > /proc/sys/net/ipv4/ip_forward

# Initialize pod network and set KUBECONFIG at centos user
echo -e "${RED}Initialize pod network and set KUBECONFIG${NC}"
sudo kubeadm init --pod-network-cidr 10.244.0.0/16
sudo export KUBECONFIG=/etc/kubernetes/admin.conf

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install flannel
echo -e "${RED}Install flannel${NC}"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Check the latest status of pod
echo -e "${RED}Check the latest status of pod${NC}"
kubectl get pods --all-namespaces
