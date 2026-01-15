#!/bin/bash
#install ssh keys
if [ $# -lt 1 ];then
	echo 'ERROR: Missing arguments'
	echo "usage $0 aula"
	exit 2
fi

aula=$1

for ip in 192.168.$aula.{1..30}
do
	echo "Installing administrador pub key in $ip..."
	sshpass -f password.txt ssh-copy-id -i ~/.ssh/iesgrao_rsa.pub -o StrictHostKeyChecking=no administrador@$ip	
done
