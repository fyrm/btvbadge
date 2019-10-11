#!/bin/bash

source /badge/bin/badge_vars.sh

msglist=( $(ls -A $DATA_MSGS/NEW_*.txt) )

if [ "$msglist" ]; then
	for i in "${msglist[@]}"; do
		newi=$i
		i=${i/NEW_/}
		if [ -f $i ]; then
			 rm -f $newi
		fi
	done
fi
