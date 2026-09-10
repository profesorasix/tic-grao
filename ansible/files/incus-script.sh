#!/bin/bash

#incus delete RAL --force 2>&1 >> incus_RAL.out
#sleep 10
incus launch images:ubuntu/noble RAL --profile default --profile X11 2>&1 >> incus_RAL.out
#sleep 10
incus start RAL
#sleep 10
incus exec RAL -- apt-get install -y bash-completion aptitude wget git zip traceroute dnsutils x11-apps fping nmap telnet 2>&1 >> incus_RAL.out
#incus exec RAL -- apt-get install -y chromium
#incus exec RAL -- bash -c 'rm google-chrome*' 2>&1 >> incus_RAL.out

#incus exec RAL -- dpkg-query -Wf '${db:Status-Status}' google-chrome-stable
if ! [ $(incus exec RAL -- dpkg-query -Wf '${db:Status-Status}' google-chrome-stable) ] 
then
	# google-chrome not installed. Install
	incus exec RAL -- wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 
	incus exec RAL -- apt -y install ./google-chrome-stable_current_amd64.deb 
fi

incus exec RAL -- bash -c 'cat > /etc/profile.d/lxc-x11.sh << EOF 
export DISPLAY=:0
export PULSE_SERVER=/mnt/pulse.sock
export export XDG_SESSION_TYPE=x11
ln -fs /mnt/X0 /tmp/.X11-unix/X0
EOF
'
incus stop RAL 2>&1 >> incus_RAL.out
touch incus_RAL_setup_completed 