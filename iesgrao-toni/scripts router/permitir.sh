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
    exit 2
    CTRL+D
    ;;
esac


$run set firewall name $nombre rule 30 disable
$run commit


exit 0
CTRL+D
