#!/bin/bash

#-----------------------------------------------------------------------------#
#                                                                             #
#   Install Kubernetes components into master node                            #
#                                                                             #
#-----------------------------------------------------------------------------#

# Change root user
sudo -i

# sudo vi /etc/hosts
# 10.0.0.45   k8s-master
# 10.0.0.7    k8s-node1
# 10.0.0.110  k8s-node2

# Setup ip_forward rule as a "1"
echo 1 > /proc/sys/net/ipv4/ip_forward

# Initialize kubeadm using Flannel
kubeadm init --pod-network-cidr=10.244.0.0/16

# Exit from root
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Change root user
sudo -i

# Add environment variable
export KUBECONFIG=/etc/kubernetes/admin.conf

# Install the latest version of Flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Check the list pods which are installed
kubectl get pods --all-namespaces

# If coredns status is not 'Running', unmark the following comments and execute the following commands
# kubectl -n kube-system get deployment coredns -o yaml | \
# sed 's/allowPrivilegeEscalation: false/allowPrivilegeEscalation: true/g' | \
# kubectl apply -f -


