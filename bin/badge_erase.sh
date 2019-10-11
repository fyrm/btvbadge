#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

source /badge/bin/badge_vars.sh

echo "removing badge configs + history"
$P/badge_delhist.sh

echo "removing and creating data partition. may take a while."
nohup $P/badge_init_part.sh >/dev/null 2>&1
