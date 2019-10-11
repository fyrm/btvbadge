#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

# Description:
# Monitors honeydb log for any new connections and writes to simple file for view on screen

source /badge/bin/badge_vars.sh

# simple hack to avoid using multitail since tail doesn't follow newly created files
for i in `egrep "^\[.*\]" /etc/honeydb/services.conf | sed -e 's/^.//' -e 's/.$//' | awk '{print tolower($0)}'`; do
	touch /badge/data/honeydb/$i.log
done

chown honeydb.honeydb -R /badge/data/honeydb/*

touch $LOG_HONEYDB_SIMPLE
touch $LOG_ALL_SIMPLE

systemctl restart honeydb-agent

while read -r line
do
	if [[ $line =~ ^(.*)[[:space:]](.*)$ ]]; then
		event=${BASH_REMATCH[1]}
		remip=${BASH_REMATCH[2]}
		remmac=$(arp $remip | grep wlan0 | awk '{print $3}')
		date=$(date '+%d%H%M')
		echo "$date $event $remmac $remip" >> $LOG_HONEYDB_SIMPLE
		echo "$date $event $remmac $remip" >> $LOG_ALL_SIMPLE
	fi
if [[ -v remip ]] && [[ -v remmac ]] && [[ -v remalg ]]; then
if ! grep -Fq "$remmac" $LOG_HONEYDB; then
unset remmac
unset remip
unset remalg
fi
fi

done < <(xtail -F /badge/data/honeydb/*.log | jq -c -a -R 'fromjson? | select(.event=="CONNECT") | { service, remote_host } | join(" ")' -a --unbuffered -r)
#done < <(cat /badge/data/honeydb/*.log | jq -c -a -R 'fromjson? | select(.event=="CONNECT") | { service, remote_host } | join(" ")' -a --unbuffered -r)
