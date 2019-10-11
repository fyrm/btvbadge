#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

# creates DHCP scope base using MAC address

printf '10.%d.%d.0\n' $(echo `ifconfig wlan0 | grep ether | awk '{print $2}' | cut -d':' -f5,6 | sed 's/://g'` | sed -r 's/(..)/0x\1 /g')
