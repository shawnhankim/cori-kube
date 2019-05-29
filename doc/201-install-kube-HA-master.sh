#!/bin/bash

set -x

RED='\033[0;31m'
NC='\033[0m'

# +-----------------------------------------------------------------------------+
# |                                                                             |
# |   Configure Kubernetes HA for Master Node                                   |
# |                                                                             |
# +-----------------------------------------------------------------------------+

# Check whether ssh is being run
eval $(ssh-agent)

# Copy ssh key (id_rsa, id_rsa.pub) to 3 master nodes

# Setup environment variable to configure HA

## Check version whether Kubernetes is at least over 1.11.1
kubelet --version

## Setup load balancer

## nc -v LOAD_BALANCER_IP PORT

### edit /root/.bash_profile for three master nodes
export KUBERNETES_VER=v1.12.2
export LOAD_BALANCER_DNS=10.113.228.217
export LOAD_BALANCER_PORT=6443
export CP1_HOSTNAME=k8s-master1
export CP1_IP=10.10.0.0.71
export CP2_HOSTNAME=k8s-master2
export CP2_IP=10.10.0.0.180
export CP3_HOSTNAME=k8s-master3
export CP3_IP=10.0.0.92

#https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Addresses:PublicIp=52.36.8.128

## Setup 1st master node

cat <<EOF> ./kubeadm-config.yaml 
apiVersion: kubeadm.k8s.io/v1alpha3
kind: ClusterConfiguration
kubernetesVersion: stable
apiServerCertSANs:
- "${LOAD_BALANCER_DNS}"
controlPlaneEndpoint: "$LOAD_BALANCER_DNS:$LOAD_BALANCER_PORT"
etcd:
  local:
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379,https://${CP1_IP}:2379"
      advertise-client-urls: "https://${CP1_IP}:2379"
      listen-peer-urls: "https://${CP1_IP}:2380"
      initial-advertise-peer-urls: "https://${CP1_IP}:2380"
      initial-cluster: "${CP1_HOSTNAME}=https://${CP1_IP}:2380"
    serverCertSANs:
      - $CP1_HOSTNAME
      - $CP1_IP
    peerCertSANs:
      - $CP1_HOSTNAME
      - $CP1_IP
networking:
    # This CIDR is a Calico default. Substitute or remove for your CNI provider.
    podSubnet: "10.244.0.0/16"
EOF

# cat <<EOF> ./kubeadm-config.yaml 
# apiVersion: kubeadm.k8s.io/v1alpha2
# kind: MasterConfiguration
# kubernetesVersion: ${KUBERNETES_VER}
# apiServerCertSANs:
# - "${LOAD_BALANCER_DNS}"
# api:
#     controlPlaneEndpoint: "$LOAD_BALANCER_DNS:$LOAD_BALANCER_PORT"
# etcd:
#   local:
#     extraArgs:
#       listen-client-urls: "https://127.0.0.1:2379,https://${CP1_IP}:2379"
#       advertise-client-urls: "https://${CP1_IP}:2379"
#       listen-peer-urls: "https://${CP1_IP}:2380"
#       initial-advertise-peer-urls: "https://${CP1_IP}:2380"
#       initial-cluster: "${CP1_HOSTNAME}=https://${CP1_IP}:2380"
#     serverCertSANs:
#       - $CP1_HOSTNAME
#       - $CP1_IP
#     peerCertSANs:
#       - $CP1_HOSTNAME
#       - $CP1_IP
# networking:
#     # This CIDR is a Calico default. Substitute or remove for your CNI provider.
#     podSubnet: "10.244.0.0/16"
# EOF

# Configure to be able to do IPv4 forwarding
sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'

# Initialize kubeadm
sudo kubeadm init --config kubeadm-config.yaml

# copy certificates to other control planes at root user
USER=centos
CONTROL_PLANE_IPS="$CP2_IP $CP3_IP"
for host in ${CONTROL_PLANE_IPS}; do
    scp /etc/kubernetes/pki/ca.crt "${USER}"@$host:
    scp /etc/kubernetes/pki/ca.key "${USER}"@$host:
    scp /etc/kubernetes/pki/sa.key "${USER}"@$host:
    scp /etc/kubernetes/pki/sa.pub "${USER}"@$host:
    scp /etc/kubernetes/pki/front-proxy-ca.crt "${USER}"@$host:
    scp /etc/kubernetes/pki/front-proxy-ca.key "${USER}"@$host:
    scp /etc/kubernetes/pki/etcd/ca.crt "${USER}"@$host:etcd-ca.crt
    scp /etc/kubernetes/pki/etcd/ca.key "${USER}"@$host:etcd-ca.key
    scp /etc/kubernetes/admin.conf "${USER}"@$host:
done
