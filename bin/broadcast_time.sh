#!/bin/bash

source /badge/bin/badge_vars.sh

function badge_update_flash {
  if [ -f /badge/admin/flash_on_update.txt ]; then
    BUF="$PA/badge_update_flash.sh"
	else
		BUF=""
	fi
}
while true; do
	newdate=$(date)
	badge_update_flash
	#$PA/badge_mesh_exec_bg.sh "$PA/badge_update_flash.sh;date --set=\"$newdate\"" $SUPPRESS
	$PA/badge_mesh_exec_bg.sh "eval $BUF $SUPPRESS;date --set=\"$newdate\"" $SUPPRESS
	sleep 600
done
