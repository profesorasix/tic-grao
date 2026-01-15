#!/bin/bash
direc=$HOME/Escritorio/internet_alumnos.desktop
enejecucion=`ps aux | grep conectar_red | grep -v grep | grep -v vi | grep -v nano | grep -v mousepad | grep -v gedit | grep -v xed | wc -l`
if [ $enejecucion -eq 0 ]; then
		redes=`sudo sysctl -a | grep "net.ipv4.ip_forward = 1" | wc -l`
		if [ $redes -eq 1 ]; then
			cambio=`cat $direc | grep x2 | wc -l`
			if [ $cambio -eq 1 ]; then
				sed -i 's/x2/x1/g' "$direc"
			fi
		else
			cambio=`cat $direc | grep x1 | wc -l`
                        if [ $cambio -eq 1 ]; then
				sed -i 's/x1/x2/g' "$direc"
			fi
		fi
fi

			
