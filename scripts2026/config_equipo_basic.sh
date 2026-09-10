#!/bin/bash

##
# Set hostname
# install and config salt-minion
# Add user administrador with sudo priveledges
# Set shutdown time
# Add ssh public key
# Install and cofig fusion-inventory
##

#include util functions
. /scripts/util.sh

mensaje="/scripts/mensaje.txt"

################
# PRE
###############

# remove private key from script folder
rm -rf /scripts/id_rsa

##################
# Install packages
##################

# Official repo
apt-get update
sudo apt-get install -y aptitude gpg fusioninventory-agent

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

echo "# Iniciando proceso de configuración" > $mensaje


echo "#############################################################################"
echo "Empieza la configuración del equipo:`date`"
echo "#############################################################################"


####################
# Set hostname
###################

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

echo "Cambiando nombre de equipo"
hostnamectl set-hostname $nombre_equipo

# cuando cambias el hostname no va la interfaz grafica de sudo hasta que reinicias

sudo -u administrador zenity --no-wrap --question --title="Confirmación" --ok-label="Si" --cancel-label="No" --text "Quiere inventariar en el GLPI (SAI) el equipo $nombre_equipo ? (Si el PC es de Conselleria lo normal es inventariarlo)" 2> /dev/null 
if [ $? -eq 0 ]; then
    echo "# Inventariando el equipo..." > $mensaje
	echo "Inventariando"
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

sleep 3

echo "#############################################################################"
echo "Se ha terminado de ejecutar el script: `date`"
echo "#############################################################################"


exit 0