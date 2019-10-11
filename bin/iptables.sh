#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

iptables -F
iptables -t nat -F
iptables -t mangle -F

#iptables -A INPUT -p tcp --dport 22336 -j ACCEPT -i wlan0

#iptables -A INPUT -m mark --mark 1 -j DROP -i wlan0 # honeypot direct drop
#iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT -i wlan0 # honeypot allow established
#iptables -A INPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT -i wlan0 # honeypot allow dhcp requests
#iptables -A INPUT -p tcp --dport 22 -j ACCEPT -i wlan0 # honeypot allow ssh
#iptables -A INPUT -p tcp --dport 2222 -j ACCEPT -i wlan0 # honeypot needs to be here for redir 8080->22 to work
#iptables -A INPUT -p icmp -j ACCEPT -i wlan0 # honeypot ping the honeypot gateway
#iptables -A INPUT -j DROP -i wlan0 # honeypot cleanup rule
