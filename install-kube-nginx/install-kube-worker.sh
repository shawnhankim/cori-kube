#!/bin/bash

# 
# Declare Color Constant
#
source "./color.sh"


#
# Print Start Message
#
echo -e ""
echo -e "${BGreen}+------------------------------------------------------------------------------+${ColorOff}"
echo -e "${BGreen}|                         Install Kube Worker for Ubuntu                       |${ColorOff}"
echo -e "${BGreen}+------------------------------------------------------------------------------+${ColorOff}"

# 
# 1. Prerequisite prior to Kubernetes Installation
#
echo -e "${UCyan}\n1. Prerequisite prior to Kubernetes Installation ${ColorOff}"

    # 1.1 Disable Swap Memory
    echo -e "${Cyan}\n1.1 Disable Swap Memory ${ColorOff}"
    echo -e "* Because kubelet do not support swap memory and will not work if it is active."
    swapoff -a

    # 1.2 Install Docker 
    echo -e "${Cyan}\n1.2 Install Docker ${ColorOff}"

        # Update package index
        echo -e "${BPurple}\n* Update package index${ColorOff}"
        sudo apt update

        # Install a few prerequisite packages which let apt use packages over HTTPS
        echo -e "${BPurple}\n* Install packages to allow the use of Docker’s repository${ColorOff}"
        sudo apt install apt-transport-https ca-certificates curl software-properties-common

        # Add the GPG key for the official Docker repository to your system
        echo -e "${BPurple}\n* Add Docker's GPG key${ColorOff}"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

        # Add the stable Docker repository
        echo -e "${BPurple}\n* Add the stable Docker repository${ColorOff}"
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

        # Make sure you are about to install from the Docker repo instead of the default Ubuntu repo:
        sudo apt-cache policy docker-ce

        # Install Docker
        echo -e "${BPurple}\n* Install Docker CE${ColorOff}"
        sudo apt install docker-ce

        # Enable Docker
        echo -e "${BPurple}\n* Enable Docker${ColorOff}"
        sudo systemctl enable docker

# 
# 2. Kubernetes Installation
#
echo -e "${UCyan}\n2. Install Kubernetes${ColorOff}"

    # 2.1 Install kubelet and kubeadm 
    echo -e "${Cyan}\n2.1 Install kubelet, kubeadm  ${ColorOff}"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt update
    sudo apt install -y kubelet kubeadm 
    
    # 2.2 Join worker to master using kubeadm 
    echo -e "${Cyan}\n2.2 Join worker to master using kubeadm ${ColorOff}"
    
    export KUBEADM_TOKEN="fyvg4r.j523mf3ee7ti1atn"
    export KUBEADM_HOST_IP="10.0.46.28"
    export KUBEADM_TOKEN_HASH="55dc6b3e68c11a81ca10f6a82857d51b3d0b29a50d2cedb1a3dea258d2a134c3"
    sudo kubeadm join ${KUBEADM_HOST_IP}:6443 --token ${KUBEADM_TOKEN} \
                --discovery-token-ca-cert-hash sha256:${KUBEADM_TOKEN_HASH}

# 
# 3. Kube-bench Installation and Secured Configuration Verification
#
echo -e "${UCyan}\n3. Install kube-bench and verify Kubernetes security configuration \n${ColorOff}"
        
sudo docker run --rm -v `pwd`:/host aquasec/kube-bench:latest install        
./kube-bench worker


#
# Print Completion Message
#
echo -e ""
echo -e "${BGreen}+------------------------------------------------------------------------------+${ColorOff}"
echo -e "${BGreen}|               Has been completed the Kube worker installation                |${ColorOff}"
echo -e "${BGreen}+------------------------------------------------------------------------------+${ColorOff}"
