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

