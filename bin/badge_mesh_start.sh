#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

source /badge/bin/badge_vars.sh

ip addr flush dev wlan0
ip link set wlan0 down
ip addr add `eval $P/mac2ip.sh`/8 dev wlan0
ip link set wlan0 up

iw wlan0 set type ibss
iw dev wlan0 ibss join "$ESSID" 2462

systemctl restart avahi-daemon
