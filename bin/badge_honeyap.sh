#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

# Description:
# Runs hostapd and logs any new assocations

source /badge/bin/badge_vars.sh

WLAN0MAC=`ifconfig wlan0 2>/dev/null | grep "ether " | awk '{print $2}' 2>/dev/null`

#hostapd /etc/hostapd/hostapd-honeypot.conf -d | grep AP-STA-CONNECTED

while read -r line
do
	if [[ $line =~ wlan[0-9]:[[:space:]]AP-STA-CONNECTED[[:space:]](.*) ]]; then
		macaddr=${BASH_REMATCH[1]}
		# format: numerical day, hour, minute
		date=$(date '+%d%H%M')
		if ! grep -Fq "$macaddr" $LOG_HONEYWAP; then
			echo "$date WiFi $macaddr $HONEYSSID" >> $LOG_HONEYWAP
		else
			echo "$date WiFi $macaddr" >> $LOG_HONEYWAP_SIMPLE
			echo "$date WiFi $macaddr" >> $LOG_ALL_SIMPLE
		fi

	fi
done < <(/usr/sbin/hostapd -d $HOSTAPD_CONF_PATH/$HOSTAPD_HONEYPOT_CONF)
