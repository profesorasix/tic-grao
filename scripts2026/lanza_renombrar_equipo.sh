#!/bin/bash
enejecucion=`ps aux | grep $0 | grep -v grep | grep -v vi | grep -v nano | grep -v mousepad | grep -v gedit | grep -v xed | wc -l`
enejecucion2=`ps aux | grep renombra_equipo.sh | grep -v grep | grep -v vi | grep -v nano | grep -v mousepad | grep -v gedit | grep -v xed | wc -l`
if [ $enejecucion -lt 3 ]; then
  if [ $enejecucion2 -lt 1 ]; then
	pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY "/scripts/lanza_renombrar_equipo_log.sh" 
  fi
fi

