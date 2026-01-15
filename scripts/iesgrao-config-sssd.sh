#!/bin/bash


#Activate cache credentials

sudo sed -i -e '/^\[domain\/EDU.GVA.ES\]$/a cache_credentials = true' /etc/sssd/sssd.conf 
sudo sed -i -e'/^\[domain\/ALU.EDU.GVA.ES\]$/a cache_credentials = true' /etc/sssd/sssd.conf


#sed -i -e '/cache_credentials = true/d' /etc/sssd/sssd.conf

#ansible my_host_01  -i inventory.yaml -u administrador --become --ask-become-pass -m ansible.builtin.lineinfile -a "state=present line='cache_credentials = true' path=/etc/sssd/sssd.conf insertafter='^\[domain\/EDU\.GVA\.ES\]$'"
