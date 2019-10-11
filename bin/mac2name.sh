#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

echo -n "NPC";ifconfig wlan0 | grep ether | awk '{print $2}' | cut -d':' -f4,5,6 | sed 's/://g'
