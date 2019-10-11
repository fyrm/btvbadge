#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

source /badge/bin/badge_vars.sh

clear
rm -f /root/.bash_history
rm -f /root/.lesshst
rm -f /root/.viminfo
find / -type f -name ".swp" -exec rm -f {} \;
rm -rf /root/.vim
rm -f /root/.ssh/id_rsa

rm -rf /boot/.fseventsd
rm -rf /boot/.store.db

echo "clearing logs"
rm -rf /var/log/*
echo "clearing /badge/data"
find /badge/data/ -type f -exec rm -f {} \;

rm -f /etc/wpa_supplicant/wpa_supplicant-*.conf
echo "clearing wifi settings"
sed -i -e 's/ssid=".*"/ssid=""/' /etc/wpa_supplicant/wpa_supplicant.conf
sed -i -e 's/psk=".*"/psk=""/' /etc/wpa_supplicant/wpa_supplicant.conf

name=$($P/mac2name.sh)

echo "resetting avahi hostname"
sed -i -e "s/host-name=.*/host-name=$name/" /etc/avahi/avahi-daemon.conf

echo "resetting honeypot SSID"
sed -i -e "s/^ssid=.*/ssid=$name/" $HOSTAPD_CONF_PATH/$HOSTAPD_HONEYPOT_CONF
