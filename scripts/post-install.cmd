#!/bin/bash

#install packages
apt-get install aptitude openssh-server nfs-common kdenlive inkscape klavaro audacity libreoffice-l10n-es language-pack-gnome-es

USERS='eso1l eso2l eso3l eso4l bach1l bach2l pcpi1l pcpi2l'
GROUP=alumnos

#create users
echo "Adding users..."
for i in $USERS 
do
	/bin/bash ./useradd.sh $i $i
done

#mount network shares

mkdir -p /net/compartida

SHARE_MOUNT='server:/compartida /net/compartida nfs4 soft,intr,rsize=8192,wsize=8192'

egrep $SHARE_MOUNT /etc/fstab || { echo $SHARE_MOUNT >> /etc/fstab }}

if [ -f ./server_rsa.pub ];then
	mkdir -p /root/.ssh
	cat ./server_rsa.pub >> /root/.ssh/authorized_keys
fi
