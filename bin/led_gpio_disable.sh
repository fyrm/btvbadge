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
LEDS=(27 17 22 9 25 7 5 4)

function bling_init() {
  for i in ${LEDS[@]}; do
    echo ${i} > /sys/class/gpio/unexport
    echo ${i} > /sys/class/gpio/export
    echo "out" > /sys/class/gpio/gpio${i}/direction
  done
}

bling_init
