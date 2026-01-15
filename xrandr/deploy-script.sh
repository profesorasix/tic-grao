#!/bin/bash

if [ $(id -u) -ne 0 ]
then
	echo "ERROR: This script needs to be run with priviledged permissions. Run as sudo"
	exit 1
fi
tmp=$(xdg-user-dir DESKTOP)
tmp=${tmp##*/}
DESKTOP_NAME=${tmp:-Escritorio}

#Copy needed files to system dir
cp xprofile-aulas.sh /usr/local/bin
cp proyector.desktop /etc/skel/$DESKTOP_NAME
chmod 755 /etc/skel/$DESKTOP_NAME/proyector.desktop

#Copy needed files in desktop user folder
for user in `getent passwd {1000..1100} | awk -F : '{print $1}'`
do
	cp proyector.desktop /home/$user/$DESKTOP_NAME
	chmod 755 /home/$user/$DESKTOP_NAME/proyector.desktop
	chown $user:$user /home/$user/$DESKTOP_NAME/proyector.desktop
done