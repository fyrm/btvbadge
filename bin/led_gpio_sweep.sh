#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

#LED1 = pin 11, BCM 17, GPIO 17
#LED2 = pin 13, BCM 27, GPIO 27
#LED3 = pin 15, BCM 22, GPIO 22
#LED4 = pin 21, BCM 9, GPIO 9
#LED5 = pin 22, BCM 25, GPIO 25
#LED6 = pin 26, BCM 7, GPIO 7
#LED7 = pin 29, BCM 5, GPIO 5
#LED8 = pin 7, BCM 4, GPIO 4

# BCM pin values

source /badge/bin/badge_vars.sh

SLEEP=".005"
SLEEP2=".001"

function bling_sweep() {
	for i in `seq 1 8`; do
		((next=i+1))
		eval $P/led_gpio.sh $i on
		sleep $SLEEP2
		eval $P/led_gpio.sh $next on
		sleep $SLEEP
		eval $P/led_gpio.sh $i off
	done
}

bling_sweep
