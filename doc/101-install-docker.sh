#!/bin/bash

#-----------------------------------------------------------------------------#
#                                                                             #
#   Install Docker before Kubernetes is installed                             #
#                                                                             #
#-----------------------------------------------------------------------------#

# Change root user
sudo -i

# Update yum
yum update

# Install package to add repository
yum install -y yum-utils      \
device-mapper-persistent-data \
lvm2

# Register repository by stable version
yum-config-manager \
--add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker CE : need to automatically select 'y'
yum install docker-ce

# Execute Docker and register it into system
systemctl start docker
systemctl enable docker

# Add userID to docker group
usermod -aG docker centos
/usr/sbin/usermod -aG docker centos

# Logout

# Check whether Docker is successfully installed
docker run hello-world
