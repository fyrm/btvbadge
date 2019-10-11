#!/usr/bin/env python
'''
DrinkWheel.py
'''
import sys
sys.path.append('/badge/bin/badge_led_helper')
import badge_led_helper
import sys
from random import *
import math
import traceback

#
#	GLOBAL VARIABLES
#
WHEEL_FULL = ["8","7","6","5","4","3","2","1"]
DELAY_SHORT = 0.04
DELAY_NORMAL = 0.08
DELAY_LONG = 0.12
DELAY_SLOMO = 0.25
DEFAULT_WHEEL_FULL_SHORT = 3
DEFAULT_WHEEL_FULL_NORMAL = 2
DEFAULT_WHEEL_FULL_LONG = 1
DEFAULT_WINNER = randint(1,8)
DEFAULT_WINNER_LED_LIST_LENGTH = 16

#
#	The main show
#
if __name__ == '__main__':
	winner = DEFAULT_WINNER
	winner_int = int(winner)
	wheel_last_round = []
	winner_led_list = []
	jackpot_led = []
	if sys.argv[1]:
		try:
			winner = sys.argv[1]
		except:
			pass
		try:
			if sys.argv[2]:
				for i in range(s):
					jackpot_led.append("12345678")
					jackpot_led.append("0")
				badge_led_helper.led_single_run_list(jackpot_led, DELAY_SHORT)
		except:
			#	do some error checking
			try:
				winner_int = int(winner)
			except:
				winner_int = math.floor(winner)
			if winner_int < 1:
				winner_int = 1
			elif winner_int > 8:
				winner_int = 8
			#	populate lists for last round wheel (stops at the winning LED) and winner celebration (flicker the winning LED)
			for i in range(8-winner_int+1):
				wheel_last_round.append(str(8-i))
			for i in range(DEFAULT_WINNER_LED_LIST_LENGTH):
				winner_led_list.append(winner)
				winner_led_list.append("0")
			#	send wheel LED lists to badge_led_helper.led_single_run_list
			#		start with short delay, then normal delay, then slower/longer delay, a very slow delay for last round, and finally the winner celebration
			for i in range(DEFAULT_WHEEL_FULL_SHORT):
				badge_led_helper.led_single_run_list(WHEEL_FULL, DELAY_SHORT)
			for i in range(DEFAULT_WHEEL_FULL_NORMAL):
				badge_led_helper.led_single_run_list(WHEEL_FULL, DELAY_NORMAL)
			for i in range(DEFAULT_WHEEL_FULL_LONG):
				badge_led_helper.led_single_run_list(WHEEL_FULL, DELAY_LONG)
			badge_led_helper.led_single_run_list(wheel_last_round, DELAY_SLOMO)
			badge_led_helper.led_single_run_list(winner_led_list, DELAY_SHORT)
