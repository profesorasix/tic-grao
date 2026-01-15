#!/bin/bash

#create VM
incus launch images:ubuntu/noble --vm --profile default nfs
incus exec nfs -- bash -c 'apt-get install aptitude nfs-kernel-server wget vim nano git bash-completion'


#clients
aptitude install nfs-common
mount -t nfs -o ro,default host:/remote/export /local/directory

subo bash -c "mkdir -p /mnt/nfs"
sudo bash -c "echo 192.168.15.101:/shared	/mnt/nfs	nfs	ro,defaults 0 0" >> /etc/fstab

#server

aptitude install nfs-kernel-server
incus exec nfs --  bash -c "mkdir -p /shared"
incus exec nfs --  bash -c 'echo -e "/shared\t\t*(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports'

#restart service