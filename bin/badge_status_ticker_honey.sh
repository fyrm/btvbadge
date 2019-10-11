#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

source /badge/bin/badge_vars.sh

prev=0

while true; do
	a=$(tput sc;tput cup 15 0)
	z=$(tput rc)
	b0="                                   "
	b=$(tput cup 15 0;tail -1 /badge/data/log-all-simple.txt)
	c="${a}${b0}${b}${z}"
	echo -n "$c" > $CONSOLE

	prev=$status
	sleep 30
done
