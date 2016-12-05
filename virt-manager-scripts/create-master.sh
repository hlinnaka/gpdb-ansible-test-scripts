#!/bin/bash

set -e

SSH_KEY_PUB=`cat gpdb-ssh-key.pem.pub`

# Create kickstart files

cat - anaconda-common.cfg > anaconda-master.cfg <<EOF
### Master-specific kickstart portion

# Network information
# Master has two NICs:
#  eth0 is the isolated network, for communicating with the segments.
#  eth1 is connected to the rest of the world.
network  --bootproto=static --device=eth0 --ipv6=auto --activate --onboot=true --ip=192.168.120.254 --netmask=255.255.255.0
network  --bootproto=dhcp --device=eth1 --ipv6=auto --activate --onboot=true
network  --hostname=gpdb-test-master

## The rest of this file was copied from anaconda-common.cfg
## END

EOF

# append to end of kickstart file
cat >> anaconda-master.cfg <<EOF
# Authorize login with ssh key
%post
mkdir /home/centos/.ssh
cat > /home/centos/.ssh/authorized_keys <<END_SSH_KEY_FILE
$SSH_KEY_PUB
END_SSH_KEY_FILE
chown centos.centos /home/centos/.ssh
chown centos.centos /home/centos/.ssh/authorized_keys
%end
EOF

ssh-keygen -R 192.168.120.254

virt-install --connect=qemu:///system --name gpdb-test-master-vm --memory 1224 --disk size=4 --location=./CentOS-7-x86_64-DVD-1511.iso --initrd-inject=anaconda-master.cfg --extra-args "ks=file:/anaconda-master.cfg" --network=network=gpdb-network --network=default --vcpus=4 --noautoconsole
