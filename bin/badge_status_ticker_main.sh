#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

source /badge/bin/badge_vars.sh

prev=0

while true; do
	status=$($P/badge_mesh_list.sh | wc -l)

	newmsgs=""

	if [ "$status" -gt "0" ]; then
		bar="["
		for i in `seq 1 $status`; do
			bar+="█"
			# 25 is the max we can display, accouting for the adjustment below of the < 10 and <100 logic
			if [ "$i" -gt "19" ]; then
				break
			fi
		done
		for j in `seq $status 19`; do
			bar+="."
		done
		bar+="]"
	fi

	if [ "${#status}" == "1" ]; then spc="  "; fi
	if [ "${#status}" == "2" ]; then spc=" "; fi
	if [ "${#status}" == "3" ]; then spc=""; fi

	curssid=$(iwconfig wlan0 | grep ESSID | sed 's/[:"]/ /g' | awk '{print $5}')
  if [ "$curssid" != "$ESSID" ]; then
		msg="badgenet off"
		status=""
	else
		msg="nearby badges:"
	fi

  $P/prune_msgs.sh
  numnew=$(ls 2>/dev/null -Ubad1 -- $DATA_MSGS/NEW_*.txt | wc -l)
  if [[ $numnew > 1 ]]; then
    newmsgs="new msgs: $numnew"
  elif [[ $numnew -eq 1 ]]; then
		newmsgs="new msg: 1"
	elif [[ $numnew -eq 0 ]]; then
    newmsgs=""
  fi

	a=$(tput sc;tput cup 15 0)
	aa=$(tput cup 16 0)
	z=$(tput rc)
	c="${a}$newmsgs${aa}$msg $status$spc$bar${z}"
	echo -n "$c" > $CONSOLE

	prev=$status
	sleep 30
done
