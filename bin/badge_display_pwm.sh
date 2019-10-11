#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

source /badge/bin/badge_vars.sh

if [ -f $PWM_FILE ]; then
	cur_pwm=$(cat $PWM_FILE)
	case "$cur_pwm" in
		50) new_pwm=150;l=2/5;;
		150) new_pwm=300;l=3/5;;
		300) new_pwm=500;l=4/5;;
		500) new_pwm=700;l=5/5;;
		700) new_pwm=50;l=1/5;;
		*) exit ;;
	esac

	echo $new_pwm > $PWM_FILE

	#FIXME tput doesn't work when script called from python
	#a=$(tput sc;tput cup 1 36)
	#b=$(tput rc)
	#c="${a}${l}${b}"
	#echo -n "$c" > $CONSOLE

	gpio -g pwm $PWM_PIN $new_pwm

else
	echo 500 > $PWM_FILE
fi
