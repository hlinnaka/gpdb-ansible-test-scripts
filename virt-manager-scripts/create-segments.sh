#!/bin/bash

SSH_KEY_PUB=`cat gpdb-ssh-key.pem.pub`

for ((i = 1; i <= 2; i++)) do
    ssh-keygen -R 192.168.120.10$i

    cat - anaconda-common.cfg > anaconda-seg$i.cfg <<EOF

cdrom
### Segment-specific kickstart portion (seg$i)

# Network information
network  --bootproto=static --device=eth0 --ipv6=auto --activate --onboot=true --ip=192.168.120.10$i --netmask=255.255.255.0
network  --bootproto=dhcp --device=eth1 --ipv6=auto --activate --onboot=true
network  --hostname=gpdb-test-seg$i
EOF

    # append to end of kickstart file
    cat >> anaconda-seg$i.cfg <<EOF
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

    virt-install --connect=qemu:///system --name gpdb-seg$i-vm --memory 1224 --disk size=5 --location=CentOS-7-x86_64-DVD-1511.iso --initrd-inject=anaconda-seg$i.cfg --extra-args "ks=file:/anaconda-seg$i.cfg" --network=network=gpdb-network --network=default --vcpus=2 --noautoconsole
done
