#!/bin/bash

if [[ $1 == "on" ]]; then
	echo 0 > /sys/class/leds/led0/brightness
else
	echo 1 > /sys/class/leds/led0/brightness
fi
