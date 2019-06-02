
#----------------------------------------------------------------------
# Kubernetes Installation
#----------------------------------------------------------------------

# Update the existing list of packages
sudo apt update

# Install docker
sudo apt install docker.io
docker --version

# Enable Docker
sudo systemctl enable docker

# Add the Kubernetes signing key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

# Add Xenial Kubernetes Repository
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# Install kubeadm
sudo apt install kubeadm
kubeadm version

#----------------------------------------------------------------------
# Kubernetes Deployment
#----------------------------------------------------------------------

# Disable swap memory (if running)
sudo swapoff -a

# Give unique hostname 
sudo hostnamectl set-hostname master-node

# Initialize Kubernetes
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Your Kubernetes control-plane has initialized successfully!

# To start using your cluster, you need to run the following as a regular user:

#   mkdir -p $HOME/.kube
#   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#   sudo chown $(id -u):$(id -g) $HOME/.kube/config

# You should now deploy a pod network to the cluster.
# Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#   https://kubernetes.io/docs/concepts/cluster-administration/addons/

# Then you can join any number of worker nodes by running the following on each as root:

# kubeadm join 10.0.46.28:6443 --token 73ypx4.mzrlzik5diwvs0cg \
#     --discovery-token-ca-cert-hash sha256:cbf89967223d8fa6471c47207e43d6b8fdcb24a7b2d0482a16ad1a17b540969c

    