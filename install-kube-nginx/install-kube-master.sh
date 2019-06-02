#!/bin/bash

# 
# Declare Color Constant
#
ColorOff='\033[0m'        # Reset color

Black="\033[0;30m"        # Regular Black
Red="\033[0;31m"          # Regular Red
Green="\033[0;32m"        # Regular Green
Yellow="\033[0;33m"       # Regular Yellow
Blue="\033[0;34m"         # Regular Blue
Purple="\033[0;35m"       # Regular Purple
Cyan="\033[0;36m"         # Regular Cyan
White="\033[0;37m"        # Regular White

BBlack="\033[1;30m"       # Bold Black
BRed="\033[1;31m"         # Bold Red
BGreen="\033[1;32m"       # Bold Green
BYellow="\033[1;33m"      # Bold Yellow
BBlue="\033[1;34m"        # Bold Blue
BPurple="\033[1;35m"      # Bold Purple
BCyan="\033[1;36m"        # Bold Cyan
BWhite="\033[1;37m"       # Bold White

UBlack="\033[4;30m"       # Underline Black
URed="\033[4;31m"         # Underline Red
UGreen="\033[4;32m"       # Underline Green
UYellow="\033[4;33m"      # Underline Yellow
UBlue="\033[4;34m"        # Underline Blue
UPurple="\033[4;35m"      # Underline Purple
UCyan="\033[4;36m"        # Underline Cyan
UWhite="\033[4;37m"       # Underline White

#
# Print Title
#
echo -e ""
echo -e "${BGreen}+------------------------------------------------------------------------------+${ColorOff}"
echo -e "${BGreen}|     Install Kubernetes and Deploy NGINX on Kubernetes Cluster for Ubuntu     |${ColorOff}"
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

        # Remove  older Docker images
        echo -e "${BPurple}\n* Remove older Docker images${ColorOff}"
        sudo docker rmi $(sudo docker images -q)       # Remove all of containers
        sudo docker rm $(sudo docker ps -a -q)         # Remove all of images
        sudo apt remove docker docker-engine docker.io # Remove Docker
        sudo apt update                                # Update package index

        # Install a few prerequisite packages which let apt use packages over HTTPS
        echo -e "${BPurple}\n* Install packages to allow the use of Docker’s repository${ColorOff}"
        sudo apt install apt-transport-https ca-certificates curl software-properties-common

        # Add the GPG key for the official Docker repository to your system
        echo -e "${BPurple}\n* Add Docker's GPG key${ColorOff}"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

        # Add the stable Docker repository
        echo -e "${BPurple}\n* Add the stable Docker repository${ColorOff}"
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

        # Update package index
        echo -e "${BPurple}\n* Update package index${ColorOff}"
        sudo apt update

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

    # 2.1 Install kubelet, kubeadm, and kubelet 
    echo -e "${Cyan}\n2.1 Install kubelet, kubeadm, and kubelet ${ColorOff}"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt update
    sudo apt install -y kubelet kubeadm kubectl
    
    # 2.2 Configure Kubernetes master node 
    echo -e "${Cyan}\n2.2 Configure Kubernetes master node ${ColorOff}"
    
        # Get host name and private IP 
        echo -e "${BPurple}\n* Get host name and private IP ${ColorOff}"
        export HOSTNAME=$(hostname)
        export PRIVATE_IP=($(hostname -I))
        echo $HOSTNAME
        echo $PRIVATE_IP
    
        # Initialize kubeadm
        echo -e "${BPurple}\n* Initialize kubeadm using private IP address ${ColorOff}"
        sudo kubeadm init  --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=${PRIVATE_IP}
        
            #
            # The example of result after running 'kubeadm init'
            #
            
            # Your Kubernetes control-plane has initialized successfully!

            # To start using your cluster, you need to run the following as a regular user:

            #   mkdir -p $HOME/.kube
            #   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
            #   sudo chown $(id -u):$(id -g) $HOME/.kube/config

            # You should now deploy a pod network to the cluster.
            # Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
            #   https://kubernetes.io/docs/concepts/cluster-administration/addons/

            # Then you can join any number of worker nodes by running the following on each as root:

            # kubeadm join 10.0.46.28:6443 --token ivvx0x.v7stjrefmldyeh1m \
            #     --discovery-token-ca-cert-hash sha256:56a1524c4a7bdcaf96c292aacf88183a560d03372181ebbc2decc011002b068c        

        # Configure kubectl
        echo -e "${BPurple}\n* Configure kubectl ${ColorOff}"
        mkdir -p $HOME/.kube
        sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
        
        # Check the status of nodes whether it is NotReady
        echo -e "${BPurple}\n* Check the status of nodes whether it is NotReady ${ColorOff}"
        kubectl get nodes

        # Install flannel
        echo -e "${BPurple}\n* Install flannel ${ColorOff}"
        kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml        
        kubectl taint nodes ${HOSTNAME} node-role.kubernetes.io/master-
        
        # Check the status of node and pod whether all status are ready
        echo -e "${BPurple}\n* Check the status of node and pod whether all status are ready ${ColorOff}"
        kubectl wait --for=condition=ready node ${HOSTNAME} --timeout=120s
        kubectl wait --for=condition=ready pod all --timeout=120s
        kubectl get nodes,pods --all-namespaces

# 
# 3. Kube-bench Installation and Secured Configuration Verification
#
echo -e "${UCyan}\n3. Install kube-bench and verify Kubernetes security configuration \n${ColorOff}"
        
sudo docker run --rm -v `pwd`:/host aquasec/kube-bench:latest install        
./kube-bench master


# 
# 4. NGINX Deployment on Kubernetes Cluster
#
echo -e "${UCyan}\n4. Deploy NGINX on Kubernetes Cluster \n${ColorOff}"

    # Create NGINX deployment
    echo -e "${BPurple}\n* Create NGINX deployment ${ColorOff}"
    kubectl create deployment nginx --image=nginx

    # Get all available deployments
    echo -e "${BPurple}\n* Get all available deployments ${ColorOff}"
    kubectl get deployments
    
    # Describe NGINX deployment
    echo -e "${BPurple}\n* Describe NGINX deployment ${ColorOff}"
    kubectl describe deployment nginx

    # Create NGINX service which is accessible via internet
    echo -e "${BPurple}\n* Create NGINX service which is accessible via internet ${ColorOff}"
    kubectl create service nodeport nginx --tcp=80:80

    # Get the current services
    echo -e "${BPurple}\n* Get the current services ${ColorOff}"
    kubectl get svc

#
# Print End of Title
#
echo -e ""
echo -e "${BGreen}+------------------------------------------------------------------------------+${ColorOff}"
echo -e "${BGreen}|     Has been completed the Kubernetes installation and NGINX deployment      |${ColorOff}"
echo -e "${BGreen}+------------------------------------------------------------------------------+${ColorOff}"
