#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

# Description:
# Monitors cowrie.log for any new connections and writes to score file

source /badge/bin/badge_vars.sh

WLAN0MAC=`ifconfig wlan0 2>/dev/null | grep "ether " | awk '{print $2}' 2>/dev/null`

if [ ! -f $LOG_HONEYSSH ]; then
	touch $LOG_HONEYSSH
fi

while read -r line
do
	if [[ $line =~ [0-9],([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\][[:space:]]kex[[:space:]]alg,[[:space:]]key[[:space:]]alg:[[:space:]](.*)$ ]]; then
		remip=${BASH_REMATCH[1]}
		remalg=${BASH_REMATCH[2]}
		remmac=$(arp $remip | grep wlan0 | awk '{print $3}')
		# format: numerical day, hour, minute
		date=$(date '+%d%H%M')
		#echo "$date SSH $remmac $remip"
		echo "$date SSH $remmac $remip" >> $LOG_HONEYSSH_SIMPLE
		echo "$date SSH $remmac $remip" >> $LOG_ALL_SIMPLE
		#echo "FIRST: $remip $remalg $remmac"
	fi

	if [[ -v remip ]] && [[ -v remmac ]] && [[ -v remalg ]]; then
		if ! grep -Fq "$remmac" $LOG_HONEYSSH; then
			#echo "$date $WLAN0MAC ssh $remmac|||$remalg|||$remip"
			unset remmac
			unset remip
			unset remalg
		fi
	fi

done < <(tail -n 0 -f $COWRIELOG)
#done < <(tail -n 1000  $COWRIELOG)
