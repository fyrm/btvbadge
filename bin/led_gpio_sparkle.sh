#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

source /badge/bin/badge_vars.sh

SLEEP=".05"

function bling_sparkle() {
	rand=$((1 + RANDOM % 8))
	$P/led_gpio.sh $rand on
	sleep $SLEEP
	$P/led_gpio.sh $rand off
}

for i in `seq 1 15`; do
	bling_sparkle
done
