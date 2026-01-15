#!/bin/bash

sed -i s/epoptes-client/fakete/ /etc/xdg/autostart/epoptes-client.desktop
cp /usr/sbin/epoptes-client /usr/sbin/fakete
chmod o-x /usr/sbin/epoptes-client