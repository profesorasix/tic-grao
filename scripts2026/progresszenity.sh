#!/bin/bash
(
pejec=`ps aux | grep config_equipo.sh | grep -v grep | grep -v vi | grep -v nano | grep -v mousepad | grep -v gedit | grep -v xed | wc -l`
ps aux | grep config_equipo.sh | grep -v grep | grep -v vi | grep -v nano | grep -v mousepad | grep -v gedit | grep -v xed >> salida.txt
while [ $pejec -ne 0 ]
do
    sleep 1
    
    cat /scripts/mensaje.txt 2> /dev/null

    pejec=`ps aux | grep config_equipo.sh | grep -v grep | grep -v vi | grep -v nano | grep -v mousepad | grep -v gedit | grep -v xed | wc -l`
done
exit 0
) | zenity --progress  --title="Configuración equipo"  --pulsate  --text="Iniciando proceso de configuración" --no-cancel --auto-close

