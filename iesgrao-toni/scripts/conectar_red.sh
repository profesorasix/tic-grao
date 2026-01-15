#!/bin/bash
direc=$HOME/Escritorio/internet_alumnos.desktop
#scriptori=/scripts/internet_alumnos.desktop
conec="[Desktop Entry]\nName=Internet_alumnos\nComment=Conectar o desconectar Internet a los alumnos\nExec=/scripts/conectar_red.sh &> /dev/null\nIcon=/scripts/x1.png\nTerminal=false\nType=Application"
desc="[Desktop Entry]\nName=Internet_alumnos\nComment=Conectar o desconectar Internet a los alumnos\nExec=/scripts/conectar_red.sh &> /dev/null\nIcon=/scripts/x2.png\nTerminal=false\nType=Application"
iconoc="x1"
iconod="x2"
enejecucion=`ps aux | grep $0 | grep -v grep | grep -v vi | grep -v nano | grep -v mousepad | grep -v gedit | grep -v xed | wc -l`
mired=0
for miip in $(hostname -I)
do
	if [ $(echo $miip | grep 192.168.[0-9]*.101 | wc -l) -eq 1 ]; then
		mired=$(echo $miip | cut -f3 -d".")
	fi
done

if [ $mired -eq 0 ]; then
	zenity --error --title="ERROR IP" --text "Hay ocurrido un error con la IP del profesor, contacte con el coordinador TIC para que solucione el problema"  2> /dev/null
	exit 4
fi


if [ $enejecucion -lt 3 ]; then
		elestado=$(ssh -i /scripts/id_rsa -o "StrictHostKeyChecking no" -q -tt profe@192.168.10.100 /home/profe/estado.sh $mired)
		if [ $? -ne 0 ]; then
			zenity --error --title="ERROR estado" --text "Hay ocurrido al consultar el estado ($elestado), contacte con el coordinador TIC para que solucione el problema"  2> /dev/null
			exit 5
		fi
		permitido=$(echo $elestado | grep permitido | wc -l)
		if [ $permitido -eq 0 ]; then
			echo -e "$desc" > $direc
			zenity --no-wrap --question --title "INTERNET" --ok-label="Si" --cancel-label="Cancelar" --text "Los alumnos <span color=\"red\"><b>NO</b></span> tienen Internet, quiere ACTIVAR INTERNET a los alumnos?" 2> /dev/null
			if [ $? -eq 0 ]; then
				ssh -i /scripts/id_rsa -o "StrictHostKeyChecking no" -q -tt profe@192.168.10.100 /home/profe/permitir.sh $mired | zenity --progress --title="Activando Internet" --text="Activando..." --auto-close  --percentage=0
				elestado=$(ssh -i /scripts/id_rsa -o "StrictHostKeyChecking no" -q -tt profe@192.168.10.100 /home/profe/estado.sh $mired)
				if [ $? -ne 0 ]; then
					zenity --error --title="ERROR estado" --text "Hay ocurrido al consultar el estado ($elestado), contacte con el coordinador TIC para que solucione el problema"  2> /dev/null
					exit 6
				fi
				permitido=$(echo $elestado | grep permitido | wc -l)
		                if [ $permitido -eq 0 ]; then
					zenity --error --title="ERROR al activar " --text "Hay un error al conectar Internet a los alumnos, contacte con el coordinador TIC para que solucione el problema"  2> /dev/null
					exit 2
				else
					echo -e "$conec" > $direc
					#sed -i 's/x2/x1/g' "$direc"
					#sed -i 's/x2/x1/g' "$scriptori"
					zenity --no-wrap --info --title="CONECTADO" --text "Ya está ACTIVADO. Los alumnos SI tienen Internet"  2> /dev/null
					exit 0
				fi
			else
				exit 0
			fi
		else
			echo -e "$conec" > $direc
			zenity --no-wrap --question --title "INTERNET" --ok-label="Si" --cancel-label="Cancelar" --text "Los alumnos <span color=\"green\"><b>SI</b></span> tienen Internet, quiere DESACTIVAR INTERNET a los alumnos?" 2> /dev/null
			if [ $? -eq 0 ]; then
				ssh -i /scripts/id_rsa -o "StrictHostKeyChecking no" -q -tt profe@192.168.10.100 /home/profe/bloquear.sh $mired | zenity --progress --title="Desactivando Internet" --text="Desactivando..." --auto-close  --percentage=0
				elestado=$(ssh -i /scripts/id_rsa -o "StrictHostKeyChecking no" -q -tt profe@192.168.10.100 /home/profe/estado.sh $mired)
				if [ $? -ne 0 ]; then
					zenity --error --title="ERROR estado 7" --text "Hay ocurrido al consultar el estado ($elestado), contacte con el coordinador TIC para que solucione el problema"  2> /dev/null
					exit 7
				fi
				permitido=$(echo $elestado | grep permitido | wc -l)
               			if [ $permitido -eq 0 ]; then
					echo -e "$desc" > $direc
					#sed -i 's/x1/x2/g' "$direc"
					#sed -i 's/x1/x2/g' "$scriptori"
					zenity --no-wrap --info --title="DESCONECTADO" --text "YA está DESACTIVADO. Los alumnos NO tienen Internet"  2> /dev/null
					exit 0
					
				else
					zenity --error --title="ERROR al desactivar" --text "Hay un error al desconectar Internet a los alumnos, contacte con el coordinador TIC para que solucione el problema"  2> /dev/null
					exit 3
				fi
			else
				exit 0
			fi
		fi
fi

