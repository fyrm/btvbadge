#!/usr/bin/env python
'''
fireworks.py
'''
import sys
sys.path.append('/badge/bin/badge_led_helper')
import badge_led_helper

import traceback
import re
import argparse
import RPi.GPIO as GPIO
import time


#
#	fireworks_led_launch
#
def fireworks_led_launch():
	try:
		led_number_list = []
		led_number_list.append("18")
		led_number_list.append("27")
		led_number_list.append("36")
		led_number_list.append("45")
		badge_led_helper.led_single_run_list(led_number_list, 0.25, False)
	except Exception as e:
		print "fireworks_led_launch: EXCEPTION"
		print(e)
		traceback.print_exc()

#
#	fireworks_led_finale
#
def fireworks_led_finale():
	try:
		led_number_list = []
		#	simulate fireworks exploding in the sky and then falling to the ground
		#	flicker top 1-2 LEDs first
		led_number_list.append("45")
		led_number_list.append("4536")
		led_number_list.append("45")
		led_number_list.append("4536")
		#	flicker top 1-2 and 2-3 LEDs
		led_number_list.append("3627")
		led_number_list.append("4536")
		led_number_list.append("3627")
		led_number_list.append("4536")
		led_number_list.append("3627")
		#	flicker middle 2 LEDs
		led_number_list.append("1827")
		led_number_list.append("3627")
		led_number_list.append("1827")
		led_number_list.append("3627")
		led_number_list.append("1827")
		led_number_list.append("3627")
		#	flicker bottom 1-2 LEDs last
		led_number_list.append("1827")
		led_number_list.append("18")
		led_number_list.append("1827")
		led_number_list.append("18")
		badge_led_helper.led_single_run_list(led_number_list, 0.1, False)
	except Exception as e:
		print "fireworks_led_finale: EXCEPTION"
		print(e)
		traceback.print_exc()


if __name__ == '__main__':
	if (sys.argv[1] == "fireworks_led_launch" or sys.argv[1] == "launch"):
		fireworks_led_launch()
	elif (sys.argv[1] == "fireworks_led_finale" or sys.argv[1] == "finale"):
		fireworks_led_finale()
