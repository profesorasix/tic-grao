#!/bin/bash

# Script para la configuración de equipos lliurex gestionados por el SAI
# Tareas
# Crear usuario administrador
# Asignar ip estática en función de su ubicación en el aula
# Instalar paquetes adicionales
# Instalar y configurar epoptes-client
# Instalar y configurar cliente salt-minion para gestión remota
# Configurar apagado a las 22
# Add public ssh key
##

#include util functions
. /scripts/util.sh

##################
# Install packages
##################

# Official repo
apt-get update
sudo apt-get install -y aptitude traceroute gpg git epoptes openssl openssh-server autofs

# saltstack project repository

# Ensure keyrings dir exists
mkdir -m 755 -p /etc/apt/keyrings
# Download public key
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | gpg --dearmor | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp > /dev/null
# Create apt repo target configuration
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources

apt-get update
apt-get install -y salt-minion
echo "master: salt-master.ies.grao" > /etc/salt/minion.d/master.conf
systemctl enable salt-minion && systemctl start salt-minion

###############################
# Add adminstrador user as sudo
###############################

#MD5 password
useradd -d /home/administrador -G sudo -m -p '$1$ZepJ2mlF$At8rJFaE7q5tqYppo.TyY.' administrador

################################
# Add public ssh key
################################
ssh_grao_pub='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCywyyt8I3qy2WFOxoeJzpE5uG5/vdLG
bsPyJ8Ko7nblXNcAmRR2mcDbqUwZ3oq3HbdAEIMxyBV5c1KPhhvBi8VbKmY+sVV6zxLtg7ySsZNFP3i4bl8
OaUTPdk4RbfwistbDaDd84W01Thrfn9bIPx+oLE1mk+UIQem32y0JS7H/oWFPisnOzXeG4XmvClpdoWgWU0
Hf/RK1HAz+XSK9Gy5M4q8vGCxauK4ZMs2cB53wbRCS4EHdcjfcB/AU0rFPlk2uTXw900MMiDI0TvWjO4VZB
VxyA3J7QqYOFp9KzeCFx6j6RsYbgCBHHxEAiPngbvADYDCing772qwk2pRziE2LlGWjNL2OL3gZUa5QJRPO
yko837e+nnpx2t9ji5LSPryPzQ1dAluZgV8dnSM3yjJpPhsf6D0lCMI1/SsKcAqmNAleFF2hLUT9maZ8Psz
hNoBwU7IcPY9QdSAgXVkcVl/udCV1c4d/iJXlJzfoIOgLhLN1rBsyA1plbsFQRBcrdM= carlossg@aulaxxxpczz'

##remove all characters (\t,\n\) from variable
mkdir -p /home/administrador/.ssh/
echo "${ssh_grao_pub//[$'\n'$'\t']}" >> /home/administrador/.ssh/authorized_keys

############################
# Add shutdown task at 22:30
############################

(crontab -l 2>/dev/null; echo "30 22 * * * /sbin/shutdown -P now") | crontab -



# variables usadas el el script
aulasinconfig="aulaxxxpc" # Nombre del pc cuando se acaba de clonar
ignorarinterfaces='^lo$|virbr' # Nombre de las interfaces a ignorar una linea (virt hay que ignorar todas)
ignorarinterfacesconespacio=' lo$|virbr' # Nombre de las interfaces a ignorar dos lineas (con espacio y virt hay que ignorar todas)

pcprofconnat="false" # configurar el pc del profesor con NAT (true o false) SE PREGUNTA LUEGO
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
# aula por ejemplo 24 y se usará para la configuracion de la red del aula, por ejemplo 192.168.24.0 y en el caso del pc del profesor con dos tarjetas de red y nat se usará de ip externa, por ejemplo 192.168.10.24
# pccontresdig por 007
# pccondosdig por ejemplo 07 y se usará para el nombre del PC, por ejemplo aula024pc07
# pc por ejemplo 7 y se usará para la configuracion de la ip, por ejemplo 192.168.24.7

# variables para las interfaces, si se modifican estas variables hay que modifcar tb columnwaninterfaces que esta mas abajo
numinterfaces=$(ip a s | grep ^[0-9] | tr -d " " | cut -d":" -f2 | grep -v -E "$ignorarinterfaces" | wc -l)
interfaces=$(ip a s | grep ^[0-9] | tr -d " " | cut -d":" -f2 | grep -v -E "$ignorarinterfaces")
columninterfaces=$(ip a s | grep ^[0-9] | tr -d " " | cut -d":" -f1,2 | tr ":" " " | grep -v -E "$ignorarinterfacesconespacio")

echo "# Iniciando proceso de configuración" > $mensaje

nohup /scripts/progresszenity.sh  & #>/dev/null 2>&1 &


echo "#############################################################################"
echo "Empieza la configuración del equipo:`date`"
echo "#############################################################################"


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

#########################################################
# assign static ip based on its position in the classroom
#########################################################

echo "# Configurando interfaces" > $mensaje

if [ $numinterfaces -eq 0 ]; then # No hay interfaz de red
	zenity --error --no-wrap --title="ERROR" --text "No hay interfaces de red. Comprueba que tengas tarjeta de red y vuelve a intentarlo.\nSaliendo de la configuración del equipo. No se ha efectuado ningún cambio. "  2> /dev/null
    echo "Se sale de la configuración (error interfaces): `date`"
	exit 1

elif [ $numinterfaces -eq 1 ]; then # Solo hay una interfaz de red
    interfclase=$interfaces

else # hay mas de una interfaz de red
    if [ $pc -eq 0 ]; then # Es el PC del profesor
	pcprofconnat="false"

        # Tiene que elegir una interfaz
        salir="false"
        while [ $salir == "false" ]
        do
            interfclase=$(zenity --list --title="Interfaz Clase"  --ok-label="Aceptar" --cancel-label="Salir de la configuración" --text="Selecciona una interfaz para la red de clase:" --radiolist --column="" --column="Interfaces" $columninterfaces)
            
            if [ $? -eq 0 ]; then
                if [ $interfclase ]; then
                    salir="true"
                fi
            else
                zenity --no-wrap --info --title="Saliendo (5)" --text "Saliendo de la configuración del equipo. No se ha efectuado ningún cambio. \nRevise el log /scripts/configurar_equipo.log"  2> /dev/null
                echo "Se sale de la configuración (5): `date`"
                exit 2
            fi
        done   

    else # NO es el PC del profesor
        # elija una interfaz para la red de clase
        echo  "Tiene que elegir una interfaz"
        salir="false"
        while [ $salir == "false" ]
        do
                interfclase=$(zenity --list --title="Interfaz Clase"  --ok-label="Aceptar" --cancel-label="Salir de la configuración" --text="Selecciona una interfaz para la red de clase:" --radiolist --column="" --column="Interfaces" $columninterfaces)
                if [ $? -eq 0 ]; then
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

fi    

echo "Mostramos la configuración por si quiere seguir o salir"

echo "# Mostrando configuración elegida" > $mensaje

if [ $pc -eq 0 ]; then # Es el PC del profesor
    echo "Configuración del PC profesor"
    if [ $pcprofconnat == "false" ]; then # Si no hay NAT 
        echo "No hay NAT"
        ipclase=$clase.$aula.$ipprofesinnat/24
        redclase=$clase.$aula.0/24
        redclase_sin=$clase.$aula.0
        gwclase=$clase.$aula.$ipprofe
        server=$clase.$aula.$ipprofesinnat

        echo "ipclase=$clase.$aula.$ipprofesinnat/24"
        echo "redclase=$clase.$aula.0/24"
        echo "redclase_sin=$clase.$aula.0"
        echo "gwclase=$clase.$aula.$ipprofe"
        echo "server=$clase.$aula.$ipprofesinnat"

        zenity --no-wrap --question --title="Confirmación" --ok-label="Si" --cancel-label="Salir de la configuración" --text "Esta es la configuración que se aplicará a su equipo: \nNombre del equipo:$nombre_equipo \nInterfaz clase:$interfclase \nIP clase:$ipclase \nRed de clase con mascara:$redclase \nRed de clase sin mascara:$redclase_sin \nPuerta de enlace:$gwclase \nDNS:$dns \nServer:$server\nA partir de aquí se empezarán a hacer cambios en el equipo. ¿Está seguro de que quiere continuar? " 2> /dev/null
        
        if [ $? -ne 0 ]; then
            zenity --no-wrap --info --title="Saliendo (18)" --text "Saliendo de la configuración del equipo. No se ha efectuado ningún cambio. \nRevise el log /scripts/configurar_equipo.log"  2> /dev/null
            echo "Se sale de la configuración (18): `date`"
            exit 0
        fi
    fi
else # No es el PC del profesor
    echo "Configuración del PC alumno"
    ipclase=$clase.$aula.$pc/24
    redclase=$clase.$aula.0/24
    redclase_sin=$clase.$aula.0
    gwclase=$clase.$aula.$ipprofe

    echo "ipclase=$clase.$aula.$pc/24"
    echo "redclase=$clase.$aula.0/24"
    echo "redclase_sin=$clase.$aula.0"
    echo "gwclase=$clase.$aula.$ipprofe"

    server=$clase.$aula.$ipprofesinnat
    echo "server=$clase.$aula.$ipprofesinnat"


    zenity --no-wrap --question --title="Confirmación" --ok-label="Si" --cancel-label="Salir de la configuración" --text "Esta es la configuración que se aplicará a su equipo: \nNombre del equipo:$nombre_equipo  \nInterfaz clase:$interfclase \nIP clase:$ipclase \nRed de clase con mascara:$redclase \nRed de clase sin mascara:$redclase_sin \nPuerta de enlace:$gwclase \nDNS:$dns \nServer:$server\nA partir de aquí se empezarán a hacer cambios en el equipo. ¿Está seguro de que quiere continuar? \nAcuerdate que el PC del profesor debe estar clonado, configurado y accesible en la red->$server" 2> /dev/null 
    if [ $? -ne 0 ]; then
         zenity --no-wrap --info --title="Saliendo (8)" --text "Saliendo de la configuración del equipo. No se ha efectuado ningún cambio. \nRevise el log /scripts/configurar_equipo.log"  2> /dev/null
         echo "Se sale de la configuración (8): `date`"
         exit 0
    fi
fi

#####################################################
# Network manager setup static ip for choosen interface
#####################################################


##TO CHECK


echo "# Borrando todas la configuración de red del NetworkManager" > $mensaje

echo "Borrando todas la configuración de red del NetworkManager"
for i in `nmcli c | grep "ethernet" | grep -o -- "[0-9a-fA-F]\{8\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{12\}"`
do 
   nmcli connection delete uuid $i
   if [ $? -ne 0 ]; then
         zenity --no-wrap --error --title="Warning NetworkmManager" --text "Error borrando la configuración de la interfaz $i.  \nRevise el log /scripts/configurar_equipo.log. \nPulse aceptar para continuar ejecutando el script"  2> /dev/null
         echo "Error borrando la configuración de la interfaz $i"
   fi
done


echo "# Configurando NetworkManager" > $mensaje


echo "Configurando la red de clase en el ordenador"
nmcli con add type ethernet con-name RedClase ifname $interfclase ip4 $ipclase gw4 $gwclase ipv4.dns "$dns" ipv6.method disabled
if [ $? -ne 0 ]; then
   zenity --no-wrap --error --title="Error red clase" --text "Error creando la red de clase en el NetworkManager.  \nRevise el log /scripts/configurar_equipo.log. \nPulse aceptar para continuar ejecutando el script"  2> /dev/null
   echo "Error creando la red de clase en el NetworkmManager"
fi

# levantamos la interfaz
nmcli connection up RedClase

if [ $? -ne 0 ]; then
   zenity --no-wrap --error --title="Error levantando red clase" --text "Error levantando la red de clase en el NetworkmManager.  \nRevise el log /scripts/configurar_equipo.log. \nPulse aceptar para continuar ejecutando el script"  2> /dev/null
   echo "Error levantando la red de clase en el NetworkmManager"
fi

# configurando el networkmanager solo para administradores, ya en la imagen
cp /scripts/10-network-manager-alumnos.pkla /etc/polkit-1/localauthority/50-local.d/

mv /scripts/clase.autofs /etc/auto.master.d/

if [ $pc -eq 0 ]; then
    echo "# Eliminando cliente epoptes" > $mensaje

    echo "Eliminando epoptes cliente, igual ya está eliminado"
    apt remove -y epoptes-client 
    
    echo "Creando restricciones addons profes"
    rm -f /etc/opt/chrome/policies/managed/chrome_allowlist_policy.json
    rm -f /etc/opt/chrome/policies/managed/chrome_blocklist_policy.json
    # viejo
    # rm -f /usr/lib/firefox/distribution/policies.json 
    # nuevo
    rm -f /etc/firefox/policies/policies.json 

    cp /scripts/auto.direct_profe /etc/auto.direct
    # activamos el servicio  systemctl icono, se deshabilita
    # systemctl enable iconointernet.service 
    mv /scripts/login.group.deny /etc/
    cp /etc/skel_prof/Escritorio/*.desktop /etc/skel/Escritorio/
    cp /scripts/proyector-aulas.sh /usr/local/bin/proyector-aulas.share
    chmod +x /usr/local/bin/proyector-aulas.sh
    cp proyector.desktop /etc/skel/Escritorio/proyector.desktop

else
    echo "# Eliminando epoptes server" > $mensaje

    apt remove -y epoptes
        
    # Eliminamos las cuenta del profesor
    userdel -f -r profesor

    rm -f /home/administrador/Escritorio/epoptes.desktop

    # eliminamos ficheoros (no debria de hacer falta) Silenciamos los errores
    #rm -f /etc/skel/.config/autostart/cambiar_icono.desktop 2> /dev/null
    #rm -f /etc/skel/Escritorio/internet_alumnos.desktop 2> /dev/null
    #rm -f /home/alumno/.config/autostart/cambiar_icono.desktop 2> /dev/null
    #rm -f /home/alumnom/.config/autostart/cambiar_icono.desktop 2> /dev/null   
    #rm -f /home/alumnot/.config/autostart/cambiar_icono.desktop 2> /dev/null

    # esto si que hace falta eliminarlo
    rm -f /home/administrador/.config/autostart/cambiar_icono.desktop 2> /dev/null
    rm -f /home/administrador/Escritorio/epoptes.desktop 2> /dev/null
    rm -f /home/administrador/Escritorio/internet_alumnos.desktop 2> /dev/null

    echo "# Eliminando id_rsa" > $mensaje
    rm -f /scripts/id_rsa

    echo "# Eliminando aplicaciones" > $mensaje
    mkdir -p /usr/share/oldapplications/screensavers 2> /dev/null
    mv /usr/share/applications/org.kde.kdeconnect* /usr/share/oldapplications/ 

    mv /usr/share/applications/xtigervncviewer.desktop /usr/share/oldapplications/ 

    mv /usr/share/applications/xviewer.desktop /usr/share/oldapplications/ 

    mv /usr/share/applications/mate-session-properties.desktop /usr/share/oldapplications/ 

    mv /usr/share/applications/screensavers/*.desktop /usr/share/oldapplications/screensavers/ 

    mv /usr/share/applications/mate-appearance-properties.desktop /usr/share/oldapplications/ 

    mv /usr/share/applications/mate-theme-installer.desktop /usr/share/oldapplications/

    mv /usr/share/applications/x11vnc.desktop /usr/share/oldapplications/

    if [ $aula -eq 13 ]; then
	   cp /scripts/auto.direct_aula13 /etc/auto.direct
    elif [ $aula -eq 14 ]; then
    	cp /scripts/auto.direct_aula14 /etc/auto.direct
    elif [ $aula -eq 15 ]; then
	   cp /scripts/auto.direct_aula15 /etc/auto.direct
    elif [ $aula -eq 67 ]; then
	   cp /scripts/auto.direct_aula67 /etc/auto.direct
    elif [ $aula -eq 72 ]; then
	   cp /scripts/auto.direct_aula72 /etc/auto.direct
    elif [ $aula -eq 79 ]; then
	   cp /scripts/auto.direct_aula79 /etc/auto.direct
    elif [ $aula -eq 148 ]; then
	   cp /scripts/auto.direct_aula148 /etc/auto.direct
    elif [ $aula -eq 132 ]; then
        cp /scripts/auto.direct_aula132 /etc/auto.direct
    elif [ $aula -eq 82 ]; then
        cp /scripts/auto.direct_aula82 /etc/auto.direct
    fi
    
    rm /scripts/auto.direct_profe    
    rm /scripts/login.group.deny
    cp /etc/skel_alum/Escritorio/Packet_Tracer.desktop /etc/skel/Escritorio/

fi

echo "# Comprobando conexión" > $mensaje

echo "comprobamos la conexión "

if [ $pc -eq 0 ]; then
    pcconexion=$gwwan
else
    pcconexion=$server
fi

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
	if [ $? -eq 1 ] ; then
		zenity --no-wrap --question --title="No hay conexión con el equipo" --ok-label="Si" --cancel-label="No, salir de la configuración" --text "No hay conexión con el equipo $pcconexion. \nCompruebe que el cable de red esté correctamente instalado. \n¿Quiere volver a intentarlo?" 2> /dev/null
		
		if [ $? -ne 0 ]; then
		    zenity --no-wrap --info --title="Saliendo (10)" --text "Saliendo de la configuración del equipo. Ya se ha efectuado algún cambio.  \nRevise el log /scripts/configurar_equipo.log. \nVuelva a ejecutar el script"  2> /dev/null
            echo "Se sale de la configuración (10)"
		    exit 1
		fi
	else
		salida=1
	fi
done


echo "Parece que hay conexion"

echo "# Actualizando paquetes (apt update)" > $mensaje


echo "Actualizando paquetes (apt update), si da error es que no hay conexión a internet"

apt update


# no se puede usar $? con apt update, parece que siempre da 0

echo "Instalacion de ubuntu-drivers install, si falla ejecutalo despues de reiniciar con conexion a internet. La orden es: sudo ubuntu-drivers install"
echo "# Instalando ubuntu-drivers install" > $mensaje

echo "instalando ubuntu-drivers install:"
# no se si se puede usar $? con ubuntu-drivers install

ubuntu-drivers install

echo "si sale un error de dependencias con virtualbox lo puedes ignorar"

echo "# Cambiando nombre del equipo" > $mensaje

echo "Cambiando nombre de equipo"
hostnamectl set-hostname $nombre_equipo
if [ $? -ne 0 ]; then
    # cuando cambias el hostname no va la interfaz grafica de sudo hasta que reinicias
    sudo -u administrador zenity --no-wrap --error --title="Error hostname" --text "Se ha producido un error cambiando el hostname.  \nRevise el log /scripts/configurar_equipo.log \nPruebe a reiniciar el equipo y ejecutar el comando \nsudo hostnamectl set-hostname $nombre_equipo \n Si el problema persiste vuelva a clonar y ejecute el script. Pulse Aceptar para continuar"  2> /dev/null
    echo "Se ha producido un error cambiando el hostname. Pruebe a reiniciar el equipo y ejecutar el comando: sudo hostnamectl set-hostname $nombre_equipo  .Si el problema persiste vuelva a clonar y ejecute el script"
fi

echo "elimina las lineas de hosts para el cambio de nombre"
sed -i '/linea_configuracion/d' /etc/hosts

echo "añade las lineas de host"
echo "127.0.0.1 $nombre_equipo # linea_configuracion " | tee -a /etc/hosts > /dev/null
echo "$server server # linea_configuracion " | tee -a /etc/hosts > /dev/null

echo "# Reiniciando claves ssh" > $mensaje

echo "borra y genera las claves ssh de nuevo"
echo "Borrando claves ssh"
rm -f /etc/ssh/ssh_host_*
echo "Generando las claves ssh de nuevo"
ssh-keygen -A

if [ $pc -ne 0 ]; then
    echo "# Metiendo epoptes cliente en el Server" > $mensaje
    echo "Empenzando a meter epoptes en el server"
    epoptes-client -c
    echo "Fin de meter epoptes en el server"
fi

# cuando cambias el hostname no va la interfaz grafica de sudo hasta que reinicias


sudo -u administrador zenity --no-wrap --question --title="Confirmación" --ok-label="Si" --cancel-label="No" --text "Quiere inventariar en el GLPI (SAI) el equipo $nombre_equipo ? (Si el PC es de Conselleria lo normal es inventariarlo)" 2> /dev/null 
if [ $? -eq 0 ]; then
    echo "# Inventariando el equipo..." > $mensaje
	echo "Inventariando"
	sudo apt install -y fusioninventory-agent
	sudo cp /scripts/agent.cfg /etc/fusioninventory/
	sudo /usr/bin/fusioninventory-agent
	
    if [ $? -eq 0 ]; then
	    echo "# Equipo inventariado correctamente!" > $mensaje
	    echo "Inventariando correctamente"
	else
	    echo "# FALLO al inventariar el equipo!" > $mensaje
	    sudo -u administrador zenity --no-wrap --error --title="Error al inventariar" --text "Se ha producido un error al inventariar el equipo.  \nRevise el log /scripts/configurar_equipo.log. \nPulse Aceptar para continuar"  2> /dev/null
	fi
fi
echo "# Ya ha terminado!!!" > $mensaje
sudo -u administrador zenity --no-wrap --info --title="Finalizado" --text "Revise el fichero log /scripts/configurar_equipo.log por si ha habido algún error. \nSi no hay errores reinicie el PC e invite a Toni a una cerveza"  2> /dev/null

echo "Si no hay errores reinicie el PC e invite a Toni a una cerveza"

# cuando cambias el hsotname no va la interfaz grafica de sudo hasta que reinicias

sudo -u administrador notify-send  -i /scripts/beer2.png "Free beer" "Invita a Toni a una cerveza"
	
sleep 3


echo "#############################################################################"
echo "Se ha terminado de ejecutar el script: `date`"
echo "#############################################################################"

