#!/bin/bash

#-----------------------------------------------------------------------------#
#                                                                             #
#   Install Kubernetes components into worker node                            #
#                                                                             #
#-----------------------------------------------------------------------------#

# Change root user
sudo -i

# Join worker node to master node
kubeadm join 10.0.0.45:6443 --token eqzaye.rk8hsl5qswwhdpkp --discovery-token-ca-cert-hash sha256:1f6c58b93ebb38654268a65a5e29c74a09f8b5f9309515028e0c043e3d18c2d1

# Check the list of nodes on Kubernetes
kubectl get nodes

#
# If you are lost token and CA hash value, you could find the following ways
#

# Describe the list of token
# kubeadm token list

# Create token
# kubeadm token create

# CA certificate's hash value
# openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
# openssl dgst -sha256 -hex | sed 's/^.* //'

# kubeadm join [API_SERVER_ADDR]:[API_SERVER_PORT] --token [TOKEN] --discovery-token-ca-cert-hash sha256:[CA_HASH]



