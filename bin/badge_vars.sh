#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

# 2 digit year, 2 digit month, 2 digit day, 2 digit version
VERSION=190809

# bin path
P=/badge/bin

# admin path
PA=/badge/admin

# ramdisk path
RD=/mnt/ram

# maximum rows and columns for "full screen" dialog boxes
# this leaves one row at bottom for status messages
MAXRES="15 40"

HOSTAPD_PID=/var/run/hostapd.pid
HOSTAPD_CONF=hostapd.conf
# no trailing slash
HOSTAPD_CONF_PATH=/etc/hostapd
HOSTAPD_HONEYPOT_PID=/var/run/hostapd-honeypot.pid
HOSTAPD_HONEYPOT_CONF=hostapd-honeypot.conf

LOG_HONEYWAP=/badge/data/log-honeywap.txt
LOG_HONEYSSH=/badge/data/log-honeyssh.txt
LOG_HONEYDHCP=/badge/data/log-honeydhcp.txt
LOG_HONEYDB=/badge/data/log-honeydb.txt

LOG_HONEYWAP_SIMPLE=/badge/data/log-honeywap-simple.txt
LOG_HONEYSSH_SIMPLE=/badge/data/log-honeyssh-simple.txt
LOG_HONEYDHCP_SIMPLE=/badge/data/log-honeydhcp-simple.txt
LOG_HONEYDB_SIMPLE=/badge/data/log-honeydb-simple.txt
LOG_ALL_SIMPLE=/badge/data/log-all-simple.txt

DATA_FRIENDS=/badge/data/friends.txt

DATA_MSGS=/badge/data/messages

# HONEY SSH config
COWRIELOGS=/badge/data/ssh
COWRIECFG=/home/cowrie/cowrie/cowrie.cfg
COWRIELOG=/mnt/ram/cowrie/log/cowrie.log
HONEY_SSH_ACTUAL_PORT=8080
HONEYIF=wlan0

# HONEY WWW config
HONEYWWWLOG=/mnt/ram/honeyhttpd/logs/

# HONEY WAP DHCP server
KEA_CONF_PATH=/etc/kea
KEA_HONEYPOT_CONF=kea-dhcp4-honeypot.conf
KEA_HONEYPOT_CSV=/mnt/ram/kea-leases4.csv

KEA_DHCP_CONF=kea-dhcp4.conf

IPTABLES=$P/iptables.sh
IPTABLES_HONEYPOT=$P/iptables-honeyap.sh

SUPPRESS=">/dev/null 2>&1"

CONSOLE=/dev/tty0

# systemctl daemon-reload; systemctl restart getty@tty1.service

# warning - changing this may cause many display issues
FONT_DEFAULT=/usr/share/consolefonts/Uni3-TerminusBold14.psf
FONT_TINY=/badge/addons/tom-thumb-256.psf

DATA_HANDLE=/badge/data/handle.txt
DATA_HONEYSSID=/badge/data/honeyssid.txt
DATA_BLING_REPEAT=/badge/data/blingrepeat.txt

# badge to badge adhoc network name.  do not change
# leave this enabled for badge to badge communication, uploading of honeypot logs and updates (bug/security fixes)
# only the badgemaker (currently) has the private key
ESSID=P14U70
AVAHI=$ESSID

# dialogrc files
DRCRED=/etc/dialogrc-red
DRCCYAN=/etc/dialogrc-cyan
DRC=/etc/dialogrc

# dialog button labels
# --exit-label
LABELEXIT="back"
# --ok-button
LABELOK="ok"
# --cancel-button
LABELCANCEL="esc"

PAUSE="press 'B' to continue"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD=$(tput bold)
NC='\033[0m'

#LED1 = pin 11, BCM 17, GPIO 17
#LED2 = pin 13, BCM 27, GPIO 27
#LED3 = pin 15, BCM 22, GPIO 22
#LED4 = pin 21, BCM 9, GPIO 9
#LED5 = pin 22, BCM 25, GPIO 25
#LED6 = pin 26, BCM 7, GPIO 7
#LED7 = pin 29, BCM 5, GPIO 5
#LED8 = pin 7, BCM 4, GPIO 4

# BCM pin values
LEDS=(17 27 22 9 25 7 5 4)

# do not change
PWM_FILE=$RD/pwm.txt
PWM_PIN=18
PWM=300
