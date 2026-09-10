#!/bin/bash
#nomhostsactual=`hostname`
#nomhostsantes="aulaxxxpcxx"
aulasinconfig="aulaxxxpc"

yaconfigurado=`grep "$aulasinconfig" /etc/hosts | wc -l`
if [ $yaconfigurado -ne 0 ] ; then
    echo "El PC aun no se ha configurado, por favor configure primero el PC"
    read -n 1 -s -r -p "Presiona una tecla para finalizar el script"
    exit 0
else
    echo -n "Introduce el nombre del nuevo usuario:"
    read usuario
    correcto=`echo "$usuario" | grep "^[a-z][-a-z0-9_]*\$" | wc -l`
    if [ $correcto -ne 1 ]; then
	echo "El nombre de usuario debe empezar por una letra minúscula y sólo puede contener letras minúsculas y números"
	read -n 1 -s -r -p "Presiona una tecla para finalizar el script"
	exit 1
    fi
    echo usuario: $usuario
    tam=`echo -n $usuario | wc -c`
    if [ $tam -lt 3 ]; then
	echo "Tienes que poner por lo menos 3 carácteres en el nombre de usuario. Vuelve a intentarlo. Saliendo."
	read -n 1 -s -r -p "Presiona una tecla para finalizar el script"
	exit 2
    fi
    exisusu=`cat /etc/passwd | grep ^$usuario: | wc -l`
    existegrupo=`cat /etc/group | grep ^$usuario: | wc -l`
    if [ $exisusu -eq 0 ]; then
	    if [ $existegrupo -eq 0 ]; then
		    sudo groupadd $usuario
	    fi
	    pcprofe=`hostname | grep pc00$ | wc -l`
	    if [ $pcprofe -ne 0 ]; then
		    echo -n "Quieres que el usuario tenga permisos de administrador (s/n):"
		    read super
		    if [[ $super = "s" || $super = 'S' || $super = "si" || $super = "Si" || $super = "sI" || $super = "SI" ]]; then
                           sudo useradd -m -k /etc/skel_prof -s /bin/bash -g $usuario -G adm,dialout,fax,cdrom,floppy,tape,sudo,audio,dip,video,plugdev,kvm,lpadmin,scanner,vboxusers,libvirt,sambashare,epoptes $usuario 
			    creado=$?
		    else
			    sudo useradd -m -k /etc/skel_prof -s /bin/bash -g $usuario -G dialout,fax,cdrom,floppy,tape,audio,dip,video,plugdev,kvm,lpadmin,scanner,vboxusers,libvirt,sambashare,epoptes $usuario
			    creado=$?
		    fi
	    else # es un pc de alumno
                    sudo useradd -m -k /etc/skel_alum -s /bin/bash -g $usuario -G dialout,fax,cdrom,floppy,tape,audio,dip,video,plugdev,kvm,lpadmin,netdev,scanner,vboxusers,libvirt $usuario 
                    creado=$?
	    fi

	    if [ $creado -eq 0 ]; then
                echo "Usuario $usuario creado correctamente"
                sudo passwd $usuario
                passcam=$?
                if [ $passcam -eq 0 ]; then
                    echo "Se ha puesto la password correctamente"
                else
                    echo -e "Ha habido un error al cambiar la password del usuario $usuario, ejecute:\n sudo passwd $usuario \nen un terminal para ponerle una password"
                fi
        else
                echo "Ha habido un error al crear el usuario"
        fi
    else
	    echo "El usuario $usuario ya existe, elija otro nombre de usuario"
    fi

fi

read -n 1 -s -r -p "Presiona una tecla para finalizar el script"
