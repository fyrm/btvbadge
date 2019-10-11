#!/bin/bash

source /badge/bin/badge_vars.sh

clear > $CONSOLE
echo "shutting down" > $CONSOLE
echo 0 > /sys/class/leds/led0/brightness

$P/bling_stop_led.sh

shutdown -h now
