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
	badge_update_flash
	$PA/badge_mesh_exec_bg.sh "eval $BUF $SUPPRESS"
	/badge/admin/msg/msg-all.sh $SUPPRESS
	sleep 600
done
