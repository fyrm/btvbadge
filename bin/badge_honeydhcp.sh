#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

# Description:
# Monitors kea dhcp log for any new connections and writes to simple file for view on screen

source /badge/bin/badge_vars.sh

if [ ! -f $LOG_HONEYDHCP ]; then
	touch $LOG_HONEYDHCP
fi

while read -r line
do

	out=$(echo $line | sed 's/,/ /g')
 	outa=($out)

	remip=${outa[0]}
	remmac=${outa[1]}
	remhost=${outa[8]}

	if [[ -v remip ]] && [[ -v remmac ]]; then
		date=$(date '+%d%H%M')
		echo "$date DHCP $remmac $remip $remhost" >> $LOG_HONEYDHCP
		echo "$date DHCP $remmac $remhost" >> $LOG_HONEYDHCP_SIMPLE
		echo "$date DHCP $remmac $remhost" >> $LOG_ALL_SIMPLE
		unset remmac
		unset remip
		unset remhost
	fi

done < <(tail -n +2 -f $KEA_HONEYPOT_CSV)
