#!/bin/bash


#Official repositories
sudo apt-get -y install aptitude fping nping xclip xseltree bridge-utils libxml2-utils evince git mate-terminal bash x11-utils libc-bin coreutils iproute2 iptables mawk sed python3 python3-pip docker.io
#lightning
git clone https://github.com/ptoribi/lightning.git /opt

#vagrant
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $jammy main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant


#sublime-text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update && sudo apt-get install sublime-text

