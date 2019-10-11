#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

iptables -F
iptables -t nat -F
iptables -t mangle -F

# honeypot rules
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 22 -j REDIRECT --to-ports 2222 -i wlan0 # honeypot redirect from cowrie on 2222
iptables -t mangle -A PREROUTING -p tcp -m tcp --dport 2222 -j MARK --set-mark 1 -i wlan0 # honeypot set mark so we can drop

# ugly, running out of time
eval honeydb_rules=( $(cat /etc/honeydb/services.conf | egrep "(port.*=|enabled.*= Yes)" | xargs | sed 's/low_port/\nlow_port/g' | grep "enabled = Yes" | sed 's/ enabled = Yes.*//g' | perl -pe 's|.*?:(\d{1,5}).*?:(\d{1,5})|"iptables -t nat -A PREROUTING -p tcp -m tcp --dport \1 -j REDIRECT --to-ports \2 -i wlan0;iptables -t mangle -A PREROUTING -p tcp -m tcp --dport \2 -j MARK --set-mark 1 -i wlan0;iptables -A INPUT -p tcp --dport \2 -j ACCEPT -i wlan0;iptables -A INPUT -p tcp --dport \1 -j ACCEPT -i wlan0"|') )

for i in "${honeydb_rules[@]}"; do
	eval $i
done

iptables -A INPUT -m mark --mark 1 -j DROP -i wlan0 # honeypot direct drop
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT -i wlan0 # honeypot allow established
iptables -A INPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT -i wlan0 # honeypot allow dhcp requests
iptables -A INPUT -p udp --dport 53 -j ACCEPT -i wlan0 # honeypot allow dns requests
iptables -A INPUT -p tcp --dport 22 -j ACCEPT -i wlan0 # honeypot allow ssh
iptables -A INPUT -p tcp --dport 2222 -j ACCEPT -i wlan0 # honeypot needs to be here for redir 8080->22 to work
iptables -A INPUT -p icmp -j ACCEPT -i wlan0 # honeypot ping the honeypot gateway

# block access to real SSH
iptables -A INPUT -j DROP -p tcp --dport 22336 -i wlan0
#iptables -A INPUT -j DROP -i wlan0 # honeypot cleanup rule
iptables -A INPUT -j ACCEPT -i wlan0 # honeypot ping the honeypot gateway
