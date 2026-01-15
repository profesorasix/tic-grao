#!/bin/bash


if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <número_aula> <file>"
	exit 1
fi

aula=$1
file=$2

source tic_lib.sh
scp_copy_admin_aula $aula $file


