- Prerequisite
  - Install Docker

- Install Kubernetes

  - Change root 

$ sudo -i
#

  - Set repository and turn off SELinux

# cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
o_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
# setenforce 0
# yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
# systemctl enable kubelet && systemctl start kubelet

  - Change network configuration
# echo 1 > /proc/sys/net/ipv4/ip_forward

  - swap off

# swapoff -a

  - System configuration

# cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# sysctl --system


  - Register service and execute
  
# systemctl daemon-reload

# systemctl restart kubelet

# systemctl enable kubelet


- Additional Installation

  - Set the policy of ip_forward  
  
echo 1 > /proc/sys/net/ipv4/ip_forward

  - Initialize kubeadm when using Flannel
  
# kubeadm init --pod-network-cidr=10.244.0.0/16

# exit
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

# export KUBECONFIG=/etc/kubernetes/admin.conf


  - Install Flannel
  
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.extensions/kube-flannel-ds created

  - Check the latest yml

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml



- Confirm installation at Master Node

- If CoreDNS is not being run
 
kubectl -n kube-system get deployment coredns -o yaml | \
sed 's/allowPrivilegeEscalation: false/allowPrivilegeEscalation: true/g' | \
kubectl apply -f -

 
  