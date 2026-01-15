#!/bin/bash

#description: scp copy file to remote ip/admin
#args: $1 -> source file
#args: $2 -> ip dest address
function scp_copy_admin()
{
	file=$1
	ip=$2
	echo "Copying $file to $ip"
	scp $file administrador@$ip:~/	
}


function scp_copy_admin_aula()
{
	file=$1
	aula=$2
	echo "Copying $file to aula $aula"
	
	for ip in 192.168.$aula.{1..30}
	do
		scp_copy_admin $file $ip		
	done

}
