#!/bin/bash

#include util functions
. /scripts/util.sh


# variables usadas el el script
aulasinconfig="aulaxxxpc" # Nombre del pc cuando se acaba de clonar
ignorarinterfaces='^lo$|virbr' # Nombre de las interfaces a ignorar una linea (virt hay que ignorar todas)
ignorarinterfacesconespacio=' lo$|virbr' # Nombre de las interfaces a ignorar dos lineas (con espacio y virt hay que ignorar todas)

# pcprofconnat="true" # configurar el pc del profesor con NAT (true o false) SE PREGUNTA LUEGO
# anyadido toni sin nat
pcprofconnat="false"

borrarhomealumno="false"
# ip clase y wan
clase="192.168"
wan="192.168.10"
gwwan="192.168.10.100"
dns="192.168.10.100 8.8.8.8"
ipprofe="100" # ip de la puerta de enlace de la LAN
ipprofesinnat="101"
mensaje="/scripts/mensaje.txt"


# existen tres variables
# aulacontresdig por ejemplo 024 y se usará para el nombre del PC, por ejemplo aula024pc07
# aulasinceros por ejemplo 24 y se usará para la configuracion de la red del aula, por ejemplo 192.168.24.0 y en el caso del pc del profesor con dos tarjetas de red y nat se usará de ip externa, por ejemplo 192.168.10.24
# pccontresdig por 007
# pccondosdig por ejemplo 07 y se usará para el nombre del PC, por ejemplo aula024pc07
# pcsinceros por ejemplo 7 y se usará para la configuracion de la ip, por ejemplo 192.168.24.7

# variables para las interfaces, si se modifican estas variables hay que modifcar tb columnwaninterfaces que esta mas abajo
numinterfaces=$(ip a s | grep ^[0-9] | tr -d " " | cut -d":" -f2 | grep -v -E "$ignorarinterfaces" | wc -l)
interfaces=$(ip a s | grep ^[0-9] | tr -d " " | cut -d":" -f2 | grep -v -E "$ignorarinterfaces")
columninterfaces=$(ip a s | grep ^[0-9] | tr -d " " | cut -d":" -f1,2 | tr ":" " " | grep -v -E "$ignorarinterfacesconespacio")

echo "# Iniciando proceso de configuración" > $mensaje

nohup /scripts/progresszenity.sh  & #>/dev/null 2>&1 &

# si ya está configurado el equipo
echo "#############################################################################"
echo "Empieza la configuración del equipo:`date`"
echo "#############################################################################"

esprofesor=`grep "pc00" /etc/hosts | wc -l`
if [ $esprofesor -ne 0 ] ; then
    echo "Equipo profesor configurado"
    zenity --no-wrap --info --title="Saliendo (1)" --text "Este equipo ha sido configurado como equipo del profesor, y no se puede renombrar. No se ha efectuado ningún cambio. \nRevise el log /scripts/renombrar_equipo.log"  2> /dev/null
            echo "Se sale de la configuración (1): `date`"
            exit 0
fi

yaconfigurado=`grep "$aulasinconfig" /etc/hosts | wc -l`
if [ $yaconfigurado -ne 0 ] ; then
    echo "Equipo NO configurado"
    zenity --no-wrap --info --title="Saliendo (1)" --text "El equipo no ha sido configurado, configurelo primero. Saliendo de la ejecución para renombrar el equipo. No se ha efectuado ningún cambio. \nRevise el log /scripts/renombrar_equipo.log"  2> /dev/null
            echo "Se sale de la configuración (1): `date`"
            exit 0
fi


######################
# Ask for classroom number
######################

echo "# Configurando número aula" > $mensaje


aula="$(get_classroom)"

echo "Aula: $aula"
####################
# Ask for pc number
####################

echo "# Configurando número PC" > $mensaje
# Elejimos el número de PC

pc="$(get_pc_number)"

echo "PC:$pc"

#aulaXXXpcXX format for hostname
nombre_equipo=aula$(printf %03d $aula)pc$(printf %02d $pc)

echo "Nombre del equipo:$nombre_equipo"

# buscamos para las interfaces de red del profesor

echo "# Configurando interfaces" > $mensaje

if [ $numinterfaces -eq 0 ]; then # No hay interfaz de red
	zenity --error --no-wrap --title="ERROR" --text "No hay interfaces de red. Comprueba que tengas tarjeta de red y vuelve a intentarlo.\nSaliendo de la configuración del equipo. No se ha efectuado ningún cambio. "  2> /dev/null
    echo "Se sale de la configuración (error interfaces): `date`"
	exit 1
elif [ $numinterfaces -eq 1 ]; then # Solo hay una interfaz de red
    interfclase=$interfaces
else # hay mas de una interfaz de red
        # NO es el PC del profesor
        # elija una interfaz para la red de clase
        echo  "Tiene que elegir una interfaz"
        salir="false"
        while [ $salir == "false" ]
        do
                interfclase=$(zenity --list --title="Interfaz Clase"  --ok-label="Aceptar" --cancel-label="Salir de la configuración" --text="Selecciona una interfaz para la red de clase:" --radiolist --column="" --column="Interfaces" $columninterfaces)
                resp7=$?
                if [ $resp7 -eq 0 ]; then
                    if [ $interfclase ]; then
                        salir="true"
                    fi
                else
                    zenity --no-wrap --info --title="Saliendo (17)" --text "Saliendo de la configuración del equipo. No se ha efectuado ningún cambio. \nRevise el log /scripts/configurar_equipo.log"  2> /dev/null
                    echo "Se sale de la configuración (17): `date`"
                    exit 2
                fi
        done   
    
fi    

echo "Mostramos la configuración por si quiere seguir o salir"

echo "# Mostrando configuración elegida" > $mensaje

# No es el PC del profesor
    echo "Configuración del PC alumno"
    ipclase=$clase.$aulasinceros.$pcsinceros/24
    redclase=$clase.$aulasinceros.0/24
    redclase_sin=$clase.$aulasinceros.0
    gwclase=$clase.$aulasinceros.$ipprofe

    echo "ipclase=$clase.$aulasinceros.$pcsinceros/24"
    echo "redclase=$clase.$aulasinceros.0/24"
    echo "redclase_sin=$clase.$aulasinceros.0"
    echo "gwclase=$clase.$aulasinceros.$ipprofe"
    
    
    server=$clase.$aulasinceros.$ipprofesinnat
    echo "server=$clase.$aulasinceros.$ipprofesinnat"

    
    #   server=$clase.$aulasinceros.$ipprofe
    #   echo "server=$clase.$aulasinceros.$ipprofe"

    zenity --no-wrap --question --title="Confirmación" --ok-label="Si" --cancel-label="Salir de la configuración" --text "Esta es la configuración que se aplicará a su equipo: \nNombre del equipo:$nombreequipo \nBorrar carpeta alumno: $borrarhomealumno \nInterfaz clase:$interfclase \nIP clase:$ipclase \nRed de clase con mascara:$redclase \nRed de clase sin mascara:$redclase_sin \nPuerta de enlace:$gwclase \nDNS:$dns \nServer:$server\nA partir de aquí se empezarán a hacer cambios en el equipo. ¿Está seguro de que quiere continuar? \nAcuerdate que el PC del profesor debe estar clonado, configurado y accesible en la red->$server" 2> /dev/null 
    resp10=$?
    if [ $resp10 -ne 0 ]; then
         zenity --no-wrap --info --title="Saliendo (8)" --text "Saliendo de la configuración del equipo. No se ha efectuado ningún cambio. \nRevise el log /scripts/configurar_equipo.log"  2> /dev/null
         echo "Se sale de la configuración (8): `date`"
         exit 0
    fi


echo "# Borrando todas la configuración de red del NetworkManager" > $mensaje

echo "Borrando todas la configuración de red del NetworkManager"
for i in `nmcli c | grep "ethernet" | grep -o -- "[0-9a-fA-F]\{8\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{12\}"`
do 
   nmcli connection delete uuid $i
   resp20=$?
   if [ $resp20 -ne 0 ]; then
         zenity --no-wrap --error --title="Warning NetworkmManager" --text "Error borrando la configuración de la interfaz $i.  \nRevise el log /scripts/configurar_equipo.log. \nPulse aceptar para continuar ejecutando el script"  2> /dev/null
         echo "Error borrando la configuración de la interfaz $i"
   fi
done

echo "# Configurando NetworkManager" > $mensaje




echo "Configurando la red de clase en el ordenador"
nmcli con add type ethernet con-name RedClase ifname $interfclase ip4 $ipclase gw4 $gwclase ipv4.dns "$dns" ipv6.method disabled
resp32=$?
if [ $resp32 -ne 0 ]; then
   zenity --no-wrap --error --title="Error red clase" --text "Error creando la red de clase en el NetworkmManager.  \nRevise el log /scripts/configurar_equipo.log. \nPulse aceptar para continuar ejecutando el script"  2> /dev/null
   echo "Error creando la red de clase en el NetworkmManager"
fi

nmcli connection up RedClase
resp32=$?
if [ $resp32 -ne 0 ]; then
   zenity --no-wrap --error --title="Error levantando red clase" --text "Error levantando la red de clase en el NetworkmManager.  \nRevise el log /scripts/configurar_equipo.log. \nPulse aceptar para continuar ejecutando el script"  2> /dev/null
   echo "Error levantando la red de clase en el NetworkmManager"
fi

	


echo "# Comprobando conexión" > $mensaje

echo "comprobamos la conexión "

pcconexion=$server
#pcconexion=192.168.10.100 # quitar luego


salida=0
while [ $salida -eq 0 ]
do
	(
	for j in $(seq 2 10)
	    do
	            sleep 1
		    ping -c 1 $pcconexion 1>/dev/null 2>&1
		    accesible=$?
		    echo "${j}0"
		    echo "# Buscando equipo $pcconexion mediante ping...intento $j"
		    sleep 1
		    if [ $accesible -eq 0 ]; then
			echo "99"
			echo "# Se ha encontrado el equipo $pcconexion"
			sleep 4
			echo "100"
			echo "# Se ha encontrado el equipo $pcconexion"
		    	break
		    fi
	    done
	) |
	zenity --progress --title="Buscando $pcconexion" --text="Buscando equipo $pcconexion mediante ping...intento 1" --auto-close  --percentage=0
	ping -c 1 $pcconexion 1>/dev/null 2>&1
	accesible=$?
	if [ $accesible -eq 1 ] ; then
		zenity --no-wrap --question --title="No hay conexión con el equipo" --ok-label="Si" --cancel-label="No, salir de la configuración" --text "No hay conexión con el equipo $pcconexion. \nCompruebe que el cable de red esté correctamente instalado. \n¿Quiere volver a intentarlo?" 2> /dev/null
		resp22=$?
		if [ $resp22 -ne 0 ]; then
		    zenity --no-wrap --info --title="Saliendo (10)" --text "Saliendo de la configuración del equipo. Ya se ha efectuado algún cambio.  \nRevise el log /scripts/configurar_equipo.log. \nVuelva a ejecutar el script"  2> /dev/null
            echo "Se sale de la configuración (10)"
		    exit 1
		fi
	else
		salida=1
	fi
done


echo "Parece que hay conexion"



echo "# Cambiando nombre del equipo" > $mensaje

echo "Cambiando nombre de equipo"
hostnamectl set-hostname $nombreequipo
if [ $? -ne 0 ]; then
    # cuando cambias el hostname no va la interfaz grafica de sudo hasta que reinicias
    sudo -u administrador zenity --no-wrap --error --title="Error hostname" --text "Se ha producido un error cambiando el hostname.  \nRevise el log /scripts/configurar_equipo.log \nPruebe a reiniciar el equipo y ejecutar el comando \nsudo hostnamectl set-hostname $nombreequipo \n Si el problema persiste vuelva a clonar y ejecute el script. Pulse Aceptar para continuar"  2> /dev/null
    echo "Se ha producido un error cambiando el hostname. Pruebe a reiniciar el equipo y ejecutar el comando: sudo hostnamectl set-hostname $nombreequipo  .Si el problema persiste vuelva a clonar y ejecute el script"
fi

echo "elimina las lineas de hosts para el cambio de nombre"
sed -i '/linea_configuracion/d' /etc/hosts

echo "añade las lineas de host"
echo "127.0.0.1 $nombreequipo # linea_configuracion " | tee -a /etc/hosts > /dev/null
echo "$server server # linea_configuracion " | tee -a /etc/hosts > /dev/null

echo "cambiando nfs"

if [ $aulasinceros -eq 13 ]; then
    cp /scripts/auto.direct_aula13 /etc/auto.direct
elif [ $aulasinceros -eq 14 ]; then
    cp /scripts/auto.direct_aula14 /etc/auto.direct
elif [ $aulasinceros -eq 15 ]; then
    cp /scripts/auto.direct_aula15 /etc/auto.direct
elif [ $aulasinceros -eq 67 ]; then
    cp /scripts/auto.direct_aula67 /etc/auto.direct
elif [ $aulasinceros -eq 72 ]; then
    cp /scripts/auto.direct_aula72 /etc/auto.direct
elif [ $aulasinceros -eq 79 ]; then
    cp /scripts/auto.direct_aula79 /etc/auto.direct
elif [ $aulasinceros -eq 82 ]; then
    cp /scripts/auto.direct_aula82 /etc/auto.direct
elif [ $aulasinceros -eq 132 ]; then
    cp /scripts/auto.direct_aula132 /etc/auto.direct
elif [ $aulasinceros -eq 148 ]; then
    cp /scripts/auto.direct_aula148 /etc/auto.direct
fi


echo "# Metiendo epoptes cliente en el Server" > $mensaje
echo "Empenzando a meter epoptes en el server"
epoptes-client -c # quitar comentario luego
echo "Fin de meter epoptes en el server"

# inventariando
sudo -u administrador zenity --no-wrap --question --title="Confirmación" --ok-label="Si" --cancel-label="No" --text "Quiere inventariar en el GLPI (SAI) el equipo $nombreequipo ? (Si el PC es de Conselleria lo normal es inventariarlo)" 2> /dev/null 
respinv=$?
if [ $respinv -eq 0 ]; then
        echo "# Inventariando el equipo..." > $mensaje
	echo "Inventariando"
	sudo apt update
	sudo apt purge -y fusioninventory-agent 
	sudo apt install -y fusioninventory-agent 
	sudo cp /scripts/agent.cfg /etc/fusioninventory/
	sudo /usr/bin/fusioninventory-agent
	salinv=$?
	if [ $salinv -eq 0 ]; then
	    echo "# Equipo inventariado correctamente!" > $mensaje
	    echo "Inventariando correctamente"
	else
	    echo "# FALLO al inventariar el equipo!" > $mensaje
	    sudo -u administrador zenity --no-wrap --error --title="Error al inventariar" --text "Se ha producido un error al inventariar el equipo.  \nRevise el log /scripts/configurar_equipo.log. \nPulse Aceptar para continuar"  2> /dev/null
	    echo "Error inventariando: $salinv"
	fi
fi



# cuando cambias el hostname no va la interfaz grafica de sudo hasta que reinicias

echo "# Ya ha terminado!!!" > $mensaje

sudo -u administrador zenity --no-wrap --info --title="Finalizado" --text "Revise el fichero log /scripts/configurar_equipo.log por si ha habido algún error. \nSi no hay errores reinicie el PC e invite a Toni a una cerveza"  2> /dev/null

echo "Si no hay errores reinicie el PC e invite a Toni a una cerveza"

# cuando cambias el hsotname no va la interfaz grafica de sudo hasta que reinicias

sudo -u administrador notify-send  -i /scripts/beer2.png "Free beer" "Invita a Toni a una cerveza"
	
sleep 3


echo "#############################################################################"
echo "Se ha terminado de ejecutar el script: `date`"
echo "#############################################################################"


