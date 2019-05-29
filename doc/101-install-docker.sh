#!/bin/bash

#-----------------------------------------------------------------------------#
#                                                                             #
#   Install Docker before Kubernetes is installed                             #
#                                                                             #
#-----------------------------------------------------------------------------#


# Update yum
sudo yum update

# Install package to add repository
sudo yum install -y yum-utils      \
     device-mapper-persistent-data \
     lvm2


# Register repository by stable version
sudo yum-config-manager \
     --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker CE : need to automatically select 'y'
sudo yum install docker-ce

# Execute Docker and register it into system
sudo systemctl start docker
sudo systemctl enable docker

# Add userID to docker group
sudo usermod -aG docker centos

sudo /usr/sbin/usermod -aG docker centos

# Logout

# Check whether Docker is successfully installed
docker run hello-world
