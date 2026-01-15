#!/bin/bash
# Script to configure sssd cache

if [ $# -lt 1 ];then
	echo 'ERROR: Missing arguments'
	echo "usage $0 aula"
	exit 2
fi

aula=$1

source tic_lib.sh

for ip in 192.168.$aula.{1..30}
do
	echo "Installing and configuring sssd cache in $ip..."
	#sshpass -f password.txt ssh-copy-id -i ~/.ssh/iesgrao_rsa.pub -o StrictHostKeyChecking=no administrador@$ip
	scp_copy_admin "iesgrao-config-sssd.sh" $ip	
done


