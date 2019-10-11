#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

VER=$(grep -Po 'VERSION=\K(\d+)' /badge/bin/badge_vars.sh | tr -d '\n')
CPUS=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq`
CPUSPEED=$(echo "$CPUS / 1000" | bc)
CPUT=$(</sys/class/thermal/thermal_zone0/temp)
CPUC=$(echo "$CPUT / 100 * 0.1" | bc)
CPUF=$(echo "(1.8 * $CPUC) + 32" |bc)

WLAN0MAC=`ifconfig wlan0 2>/dev/null | grep "ether " | awk '{print $2}' 2>/dev/null`
WLAN0=`ifconfig wlan0 2>/dev/null | grep "inet " | awk '{print $2}' 2>/dev/null`

ETH0=`ifconfig eth0 2>/dev/null | grep "inet " | awk '{print $2}' 2>/dev/null`
ETH0MAC=`ifconfig eth0 2>/dev/null | grep "ether " | awk '{print $2}' 2>/dev/null`

USB0=`ifconfig usb0 2>/dev/null | grep "inet " | awk '{print $2}' 2>/dev/null`
USB0MAC=`ifconfig usb0 2>/dev/null | grep "ether " | awk '{print $2}' 2>/dev/null`

ROOT=`head -1 /root/passwd.txt`


#HOSTAPD=`ps x | awk '{print $5}' | grep -v grep | grep hostapd | cut -d'/' -f4`
#SSHD=`ps x | awk '{print $5}' | grep "/sshd" | cut -d'/' -f3`

echo "VERSiON: $VER"
echo "$CPUSPEED mHz / $CPUC'C $CPUF'F"
echo $(date)
echo $(uptime -p)

echo ""
echo "root passwd (changes on boot):"
echo "$ROOT"

if [[ $WLAN0 =~ [0-9] ]]
	then
		echo ""
		echo "WiFi:"
		echo "$WLAN0"
		echo "$WLAN0MAC"
	fi

if [[ $USB0 =~ [0-9] ]]
	then
		echo ""
		echo "USB:"
		echo "$USB0"
		echo "$USB0MAC"
	fi

if [[ $ETH0 =~ [0-9] ]]
	then
		echo ""
		echo "ETHERNET:"
		echo "$ETH0"
		echo "$ETH0MAC"
	fi

echo ""
echo "LiSTENiNG:"
netstat -plant | grep LISTEN | sed 's/[0-9]*\///' | awk '{print $4 "("$7")"}'
