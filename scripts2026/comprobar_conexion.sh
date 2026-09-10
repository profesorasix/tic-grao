#!/bin/bash
iconoc="x1"
iconod="x2"
mired=0
for miip in $(hostname -I)
do
	if [ $(echo $miip | grep 192.168.[0-9]*.101 | wc -l) -eq 1 ]; then
		mired=$(echo $miip | cut -f3 -d".")
	fi
done
# echo el aula es $mired >> /home/administrador/arriba.txt
# date >> /home/administrador/arriba.txt
elestado=$(ssh -i /scripts/id_rsa -o "StrictHostKeyChecking no" -q -tt profe@192.168.10.100 /home/profe/estado.sh $mired)
if [ $? -ne 0 ]; then
	# echo error al ver el estado $elestado >> /home/administrador/arriba.txt
	exit 1
else
	permitido=$(echo $elestado | grep permitido | wc -l)
	if [ $permitido -eq 0 ]; then
		# no hay internet
		# echo no hay internet >> /home/administrador/arriba.txt
		find /home -type f -name "internet_alumnos.desktop" -exec sed -i 's/x1/x2/g' {} \;
		# sed -i 's/x2/x1/g' /etc/skel/internet_alumnos.desktop
		# sed -i 's/x2/x1/g' /scripts/internet_alumnos.desktop
	else
                # hay internet
		# echo hay internet >> /home/administrador/arriba.txt
                find /home -type f -name "internet_alumnos.desktop" -exec sed -i 's/x2/x1/g' {} \;
                # sed -i 's/x2/x1/g' /etc/skel/internet_alumnos.desktop
                # sed -i 's/x2/x1/g' /scripts/internet_alumnos.desktop
	fi
fi
# echo fin >> /home/administrador/arriba.txt
