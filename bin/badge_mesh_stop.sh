#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

source /badge/bin/badge_vars.sh

systemctl stop avahi-daemon.socket
systemctl stop avahi-daemon

ip addr flush dev wlan0
ip link set wlan0 down
