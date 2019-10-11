#!/bin/bash
# This file was modified from the LiPoPi project and falls under GPL v3.0 license

source /badge/bin/badge_vars.sh

# GPIO Port
gpio_port="15"

# Enable GPIO
if [ ! -d "/sys/class/gpio/gpio$gpio_port" ]; then
  echo $gpio_port > /sys/class/gpio/export || { echo -e "Can't access GPIO $gpio_port" > $CONSOLE; exit 1; }
fi

# Set it to input
echo "in" > /sys/class/gpio/gpio$gpio_port/direction || { echo -e "Can't set GPIO $gpio_port to an input" > $CONSOLE; exit 1; }

# Set it as active high
echo 0 > /sys/class/gpio/gpio$gpio_port/active_low || { echo -e "Can't set GPIO $gpio_port to active high" > $CONSOLE; exit 1; }

while true;do
	if [ "`cat /sys/class/gpio/gpio$gpio_port/value`" != 1 ]; then
		a=$(tput sc;tput bold;tput setaf 3;tput cup 0 29)
		b=$(tput rc)
		c="${a}BATTERY LOW${b}"
		echo -n "${c}" > $CONSOLE
	fi
	sleep 600
done
