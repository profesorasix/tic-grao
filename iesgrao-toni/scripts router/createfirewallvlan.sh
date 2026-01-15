
#!/bin/vbash
run="/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper"

$run begin


if [ $# -ne 1 ]; then
	echo Parametros incorrectos
  exit 1
  CTRL+D
fi

case $1 in
  7)
    nombre="internetaula007"
    lavlan="1007"
    aula="7"
    ;;
  13)
    nombre="internetaula013"
    lavlan="1013"
    aula="13"
    ;;
  14)
    nombre="internetaula014"
    lavlan="1014"
    aula="14"
    ;;
  15)
    nombre="internetaula015"
    lavlan="1015"
    aula="15"
    ;;
  67)
    nombre="internetaula067"
    lavlan="1067"
    aula="67"
    ;;
  68)
    nombre="internetaula068"
    lavlan="1068"
    aula="68"
    ;;
  72)
    nombre="internetaula072"
    lavlan="1072"
    aula="72"
    ;;
  74)
    nombre="internetaula074"
    lavlan="1074"
    aula="74"
    ;;
  79)
    nombre="internetaula079"
    lavlan="1079"
    aula="79"
    ;;
  82)
    nombre="internetaula082"
    lavlan="1082"
    aula="82"
    ;;
  132)
    nombre="internetaula132"
    lavlan="1132"
    aula="132"
    ;;
  *)
    echo vlan incorrecta
    exit 1
    CTRL+D
    ;;
esac
servidores="192.168.10.200-192.168.10.250"
profesor="192.168.$aula.101"
lared="192.168.$aula.0/24"

echo Borrando las reglas si existen del firewall name $nombre
$run delete interfaces ethernet eth0 vif $lavlan firewall out name $nombre
$run delete firewall name $nombre 

echo Creando reglas vlan $lavlan firewall para aula $aula name $nombre profesor $profesor red $lared servidores $servidores


$run set firewall name $nombre default-action accept
$run set firewall name $nombre rule 10 action accept
$run set firewall name $nombre rule 10 description servidores
$run set firewall name $nombre rule 10 log disable
$run set firewall name $nombre rule 10 protocol all
$run set firewall name $nombre rule 10 source address $servidores
$run set firewall name $nombre rule 10 state established enable
$run set firewall name $nombre rule 10 state new enable
$run set firewall name $nombre rule 10 state related enable

$run set firewall name $nombre rule 20 action accept
$run set firewall name $nombre rule 20 description accept_profe
$run set firewall name $nombre rule 20 log disable
$run set firewall name $nombre rule 20 protocol all
$run set firewall name $nombre rule 20 destination address $profesor
$run set firewall name $nombre rule 20 state established enable
$run set firewall name $nombre rule 20 state new enable
$run set firewall name $nombre rule 20 state related enable


$run set firewall name $nombre rule 30 action drop
$run set firewall name $nombre rule 30 description deny_clase
$run set firewall name $nombre rule 30 log disable
$run set firewall name $nombre rule 30 protocol all
$run set firewall name $nombre rule 30 destination address $lared
$run set firewall name $nombre rule 30 state established enable
$run set firewall name $nombre rule 30 state new enable
$run set firewall name $nombre rule 30 state related enable

$run set firewall name $nombre rule 30 disable

$run set interfaces ethernet eth0 vif $lavlan firewall out name $nombre

$run commit
$run save

exit 0
CTRL+D
