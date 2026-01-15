#!/bin/bash
#install ssh keys
if [ $# -lt 1 ];then
	echo 'ERROR: Missing arguments'
	echo "usage $0 dir"
	exit 2
fi
dir=$1
for f in $(ls $1)
do
	line=$(exiftool $f | grep "Track Create Date")
	echo $line
	#: 2025:08:09 20:03:58" =~ .*([0-9]{4})\:([0-9]{2}).* ]]  && echo ${BASH_REMATCH[1]}${BASH_REMATCH[2]}
	if [[ $line =~ .*([0-9]{4})\:([0-9]{2})\:([0-9]{2})[[:space:]]([0-9]{2})\:([0-9]{2})\:([0-9]{2})$ ]]  
	then
		timestamp=${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}${BASH_REMATCH[4]}${BASH_REMATCH[5]}.${BASH_REMATCH[6]}
		echo $f "-" $timestamp
		touch -c -a -m -t$timestamp $dir/$f
	fi
done