#!/bin/bash

# enable RPI activity LED
echo 0 > /sys/class/leds/led0/brightness

/badge/bin/bling_led_shiftreg.py cleanup

shutdown -r now
