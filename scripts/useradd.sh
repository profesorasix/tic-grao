#!/bin/bash
# Script to add a user to Linux system

if [ $# -lt 2 ];then
	echo 'ERROR: Missing arguments'
	echo "usage $0 username password"
	exit 2
fi

username=$1
password=$2

if [ $(id -u) -eq 0 ]; then
	egrep "^$username" /etc/passwd > /dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
		cryptpass=$(perl -e 'print crypt($ARGV[0], "salt")' $password)
		useradd --comment $username --password $cryptpass --create-home --shell /bin/bash $username
		[ $? -eq 0 ] && echo "User $username has been added to system!" || echo "Failed to add a user $username!"

fi
else
	echo "Only root may add a user to the system"
	exit 2
fi
