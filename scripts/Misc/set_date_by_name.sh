#!/bin/bash
#install ssh keys
if [ $# -lt 1 ];then
	echo 'ERROR: Missing arguments'
	echo "usage $0 dir"
	exit 2
fi
dir=$1

for f in $(ls -R $1)
do
	ext=${f##*.}
	if [ $ext == 'jpg' ] || [ $ext == 'JPG' ]
	then
		#[[ $f =~ ^IMG[-_]([0-9]{8})[_-].+\.jpg$ ]] && echo ${BASH_REMATCH[1]}

		date=$(echo $f | sed 's/^IMG[-_]\([0-9]\{8\}\)[-_].\+\.jpg$/\1/')
		timestamp=${date}0000
		echo $f "-" $timestamp
		touch -c -a -m -t$timestamp $dir/$f
	
	elif [[ $f =~ \_([0-9]+)\_([0-9]{4})[0-9]+\.mp4 ]]
	then
		date=${BASH_REMATCH[1]}
		time=${BASH_REMATCH[2]}
		timestamp=${date}${time}
		echo $f "-" $timestamp
		touch -c -a -m -t$timestamp $dir/$f
	fi
done