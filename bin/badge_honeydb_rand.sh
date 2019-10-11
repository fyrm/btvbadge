#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

# Randomizes which HoneyDB services are enabled

source /badge/bin/badge_vars.sh

HDB=/etc/honeydb/services.conf
total=$(cat /etc/honeydb/services.conf | egrep "^enabled" | wc -l)

gotone=0

function randomize_conf {
	while read -r line; do
  	if [[ $line =~ ^enabled[[:space:]]+=[[:space:]](Yes|No) ]]; then
			# 1 in 3 chance of enabling the service
			rand=$(( ( RANDOM % 2 )  + 1 ))	
			if [[ $rand -eq 1 ]]; then
				new+=('enabled     = Yes')
				gotone=1
			else
				new+=('enabled     = No')
			fi
  	else
			new+=("$line")
		fi
	done < <(cat /etc/honeydb/services.conf)
}

# ensures we have at least 1 service enabled
while [ $gotone -eq 0 ]; do
	new=()
	line=""
	randomize_conf
done

cp $HDB $HDB.bak
rm -f $HDB
for i in "${new[@]}"; do
	echo "$i" >> $HDB
done
