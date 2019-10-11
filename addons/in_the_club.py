#!/usr/bin/env python
'''
in_the_club.py
'''
import sys
sys.path.append('/badge/bin/badge_led_helper')
import badge_led_helper
import RPi.GPIO as GPIO
import time
import uinput
import signal
import os
import subprocess
import traceback
import re
import datetime
import math
import random

#
#	GLOBAL VARIABLES
#
#	Basic patterns
NOTHING = ["0"]
LED_UP = ["45"]
LED_DOWN = ["18"]
LED_LEFT = ["67"]
LED_RIGHT = ["23"]
LED_B = ["6"]
LED_A = ["3"]
LED_SELECT = ["8"]
LED_START = ["1"]
LED_ALL = ["18273645"]
UNCE = ["18","1827","182736","1827","18"]
UNCE_BIG = ["18","1827","182736","18273645","182736","1827","18"]
UNCE_LITTLE = ["18","1827","18"]
UNCE_LEFT = ["8","87","876","87","8"]
UNCE_LEFT_BIG = ["8","87","876","8765","876","87","8"]
UNCE_LEFT_LITTLE = ["8","87","8"]
UNCE_RIGHT = ["1","12","123","12","1"]
UNCE_RIGHT_BIG = ["1","12","123","1234","123","12","1"]
UNCE_RIGHT_LITTLE = ["1","12","1"]
COUNTDOWN = ["18273645","182736","1827","18"]
COUNTUP = ["18","1827","182736","18273645"]
COUNTUP_LEFT_THREE = ["8","7","6"]
COUNTDOWN_RIGHT_THREE = ["3","2","1"]
LEFT_RIGHT_ONE = ["8","1"]
#	Defaults for number of times a pattern will be run
NUMBER_RUNS_DEFAULT = 3
NUMBER_RUNS_DEFAULT_LITTLE = 1
NUMBER_RUNS_DEFAULT_BIG = 5
NUMBER_RUNS_DEFAULT_BIGGER = 10
NUMBER_RUNS_DEFAULT_BIGGEST = 30
NUMBER_RUNS_DEFAULT_IHATEBATTERIES = 100
#	Defaults for LED timing delays
DELAY = 0.05
DELAY_SHORT = 0.03
DELAY_LONG = 0.1
DELAY_SLOMO = 0.2
#	Combinations of basic patterns
IN_THE_CLUB_FADEOUT = [{'pattern':UNCE_BIG, 'delay':DELAY_LONG}]
IN_THE_CLUB_COUNTDOWN = [{'pattern':COUNTDOWN, 'delay':DELAY_SLOMO}]
IN_THE_CLUB_COUNTUP = [{'pattern':COUNTUP, 'delay':DELAY_SLOMO}]
IN_THE_CLUB = []
for i in range(7):
	IN_THE_CLUB.append({'pattern':UNCE, 'delay':DELAY})
for i in range(2):
	#IN_THE_CLUB.append({'pattern':UNCE_LITTLE, 'delay':DELAY})
	IN_THE_CLUB.append({'pattern':LEFT_RIGHT_ONE, 'delay':DELAY})
IN_THE_CLUB_LEFT = []
for i in range(7):
	IN_THE_CLUB_LEFT.append({'pattern':UNCE_LEFT, 'delay':DELAY})
for i in range(2):
	#IN_THE_CLUB_LEFT.append({'pattern':UNCE_LEFT_LITTLE, 'delay':DELAY})
	IN_THE_CLUB_LEFT.append({'pattern':["8"], 'delay':DELAY})
IN_THE_CLUB_RIGHT = []
for i in range(7):
	IN_THE_CLUB_RIGHT.append({'pattern':UNCE_RIGHT, 'delay':DELAY})
for i in range(2):
	#IN_THE_CLUB_RIGHT.append({'pattern':UNCE_RIGHT_LITTLE, 'delay':DELAY})
	IN_THE_CLUB_RIGHT.append({'pattern':["1"], 'delay':DELAY})
#	for our Canadian friends
IN_THE_CLUB_ALL = []
IN_THE_CLUB_ALL = IN_THE_CLUB + IN_THE_CLUB_LEFT + IN_THE_CLUB_RIGHT + IN_THE_CLUB
#	An Ode to Gob
ITS_THE_FINAL_COUNTDOWN = []
ITS_THE_FINAL_COUNTDOWN.append({'pattern':COUNTUP_LEFT_THREE, 'delay':DELAY_LONG})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':["1"], 'delay':DELAY_SLOMO})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':NOTHING, 'delay':DELAY_SLOMO})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':COUNTUP_LEFT_THREE, 'delay':DELAY})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':COUNTDOWN_RIGHT_THREE, 'delay':DELAY})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':NOTHING, 'delay':DELAY_SLOMO})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':COUNTUP_LEFT_THREE, 'delay':DELAY_LONG})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':["1"], 'delay':DELAY_SLOMO})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':NOTHING, 'delay':DELAY_SLOMO})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':COUNTUP_LEFT_THREE, 'delay':DELAY})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':NOTHING, 'delay':DELAY_SHORT})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':COUNTUP_LEFT_THREE, 'delay':DELAY})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':NOTHING, 'delay':DELAY_SHORT})
ITS_THE_FINAL_COUNTDOWN.append({'pattern':COUNTDOWN_RIGHT_THREE, 'delay':DELAY_LONG})
#	of course there has to be a konami code somehow
KONAMI = []
KONAMI.append({'pattern':LED_UP, 'delay':DELAY})
KONAMI.append({'pattern':LED_UP, 'delay':DELAY})
KONAMI.append({'pattern':LED_DOWN, 'delay':DELAY})
KONAMI.append({'pattern':LED_DOWN, 'delay':DELAY})
KONAMI.append({'pattern':LED_LEFT, 'delay':DELAY})
KONAMI.append({'pattern':LED_RIGHT, 'delay':DELAY})
KONAMI.append({'pattern':LED_LEFT, 'delay':DELAY})
KONAMI.append({'pattern':LED_RIGHT, 'delay':DELAY})
KONAMI.append({'pattern':LED_B, 'delay':DELAY})
KONAMI.append({'pattern':LED_A, 'delay':DELAY})
KONAMI.append({'pattern':NOTHING, 'delay':DELAY_SLOMO})
KONAMI.append({'pattern':LED_ALL, 'delay':DELAY_SHORT})
KONAMI.append({'pattern':NOTHING, 'delay':DELAY_SHORT})
KONAMI.append({'pattern':LED_ALL, 'delay':DELAY_SHORT})
KONAMI.append({'pattern':NOTHING, 'delay':DELAY_SHORT})
KONAMI.append({'pattern':LED_ALL, 'delay':DELAY_SHORT})
KONAMI.append({'pattern':NOTHING, 'delay':DELAY_SHORT})
KONAMI.append({'pattern':LED_ALL, 'delay':DELAY_SHORT})
KONAMI.append({'pattern':NOTHING, 'delay':DELAY_SHORT})
#	a random game of pong. kind of
PONG = []
PONG_TURNS = random.randint(5,8)
pong_position = random.randint(4,5)
pong_winner = []
CLOCKWISE = -1
COUNTERCLOCKWISE = 1
led_direction = random.randint(-1,1)
while led_direction == 0:
	led_direction = random.randint(-1,1)
for turn in range(PONG_TURNS):
	#	direction_changed will prevent multiple direction changes on one side
	direction_changed = False
	while direction_changed == False:
		led_pong_position = []
		led_pong_position.append(str(pong_position))
		PONG.append({'pattern':led_pong_position, 'delay':DELAY_LONG})
		PONG.append({'pattern':NOTHING, 'delay':DELAY_SLOMO})
		pong_position_next = pong_position + led_direction
		if (pong_position_next < 1 or pong_position_next > 8):
			#	there are only 8 LEDs
			direction_changed = True
			led_direction = led_direction * -1
			pong_position_next = pong_position + led_direction
		elif (pong_position_next == 4 or pong_position_next == 5):
			pass
		else:
			switch_direction = random.randint(-1,1)
			while switch_direction == 0:
				switch_direction = random.randint(-1,1)
			if switch_direction == -1:
				direction_changed = True
			led_direction = led_direction * switch_direction
			pong_position_next = pong_position + led_direction
		pong_position = pong_position_next
	while (direction_changed == True and not (pong_position_next == 4 or pong_position_next == 5)):
		led_pong_position = []
		led_pong_position.append(str(pong_position))
		PONG.append({'pattern':led_pong_position, 'delay':DELAY_LONG})
		PONG.append({'pattern':NOTHING, 'delay':DELAY_SLOMO})
		pong_position_next = pong_position + led_direction
		pong_position = pong_position_next
PONG.append({'pattern':NOTHING, 'delay':DELAY_SLOMO})
if pong_position > 4:
	for i in range(4):
		pong_winner.append("1234")
		pong_winner.append("0")
else:
	for i in range(4):
		pong_winner.append("5678")
		pong_winner.append("0")
PONG.append({'pattern':pong_winner, 'delay':DELAY})
#
#	run until this is set to True
global GO_HOME_YOURE_DRUNK
GO_HOME_YOURE_DRUNK = False
#
#	variables to determine how long this script should run
SLEEP_TIME = 0.04
MAX_CYCLES = 100
NUMBER_OF_IMAGES = {0:204, 1:501, 2:169, 3:180}

#
#	Button Handling Stuff
#
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(26, GPIO.IN, pull_up_down=GPIO.PUD_UP) # START
GPIO.setup(19, GPIO.IN, pull_up_down=GPIO.PUD_UP) # A
GPIO.setup(13, GPIO.IN, pull_up_down=GPIO.PUD_UP) # UP
GPIO.setup(6, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # B
GPIO.setup(3, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # POWER
GPIO.setup(21, GPIO.IN, pull_up_down=GPIO.PUD_UP) # LEFT
GPIO.setup(16, GPIO.IN, pull_up_down=GPIO.PUD_UP) # DOWN
GPIO.setup(12, GPIO.IN, pull_up_down=GPIO.PUD_UP) # RIGHT
GPIO.setup(20, GPIO.IN, pull_up_down=GPIO.PUD_UP) # SELECT
GPIO.setup(5, GPIO.IN, pull_up_down=GPIO.PUD_DOWN) # POWER2

def signal_handler(sig, frame):
	GPIO.cleanup()
	sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

def interrupt_handler(channel):
	global GO_HOME_YOURE_DRUNK
	
	if channel == 19:
		#print("19 - A")
		yo_dj_spin_that_ish("A")
 		time.sleep(.01)
	elif channel == 26:
		#print("26 - START")
		GO_HOME_YOURE_DRUNK = True
		time.sleep(.01)
	elif channel == 20:
		#print("20 - SELECT")
		GO_HOME_YOURE_DRUNK = True
		time.sleep(.01)
	elif channel == 13:
		#print("13 - UP")
		yo_dj_spin_that_ish("UP")
		time.sleep(.01)
	elif channel == 6:
		#print("6 - B")
		yo_dj_spin_that_ish("B")
		time.sleep(.01)
	elif channel == 21:
		#print("21 - LEFT")
		yo_dj_spin_that_ish("LEFT")
		time.sleep(.01)
	elif channel == 16:
		#print("16 - DOWN")
		yo_dj_spin_that_ish("DOWN")
		time.sleep(.01)
	elif channel == 12:
		#print("12 - RIGHT")
		yo_dj_spin_that_ish("RIGHT")
		time.sleep(.01)
	elif channel == 3:
		#print("3 - POWER")
		GO_HOME_YOURE_DRUNK = True
		time.sleep(.01)
	elif channel == 5:
		#print("5 - POWER")
		GO_HOME_YOURE_DRUNK = True
		time.sleep(.01)

# 200 default
GPIO.add_event_detect(26, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(19, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(13, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(6, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(3, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(21, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(16, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(12, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(20, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(5, GPIO.RISING, callback=interrupt_handler, bouncetime=200)

#
#	Functions based on button pushed
#
def yo_dj_spin_that_ish(button):
	try:
		global GO_HOME_YOURE_DRUNK

		if button == "UP":
			badge_led_helper.led_single_run_list(NOTHING, DELAY, False)
			for beats in IN_THE_CLUB_ALL:
				badge_led_helper.led_single_run_list(beats['pattern'], beats['delay'], False)
		elif button == "DOWN":
			for i in range(3):
				badge_led_helper.led_single_run_list(NOTHING, DELAY, False)
				for beats in ITS_THE_FINAL_COUNTDOWN:
					badge_led_helper.led_single_run_list(beats['pattern'], beats['delay'], False)
				badge_led_helper.led_single_run_list(NOTHING, DELAY_SLOMO, False)
		elif button == "LEFT":
			for i in range(3):
				badge_led_helper.led_single_run_list(NOTHING, DELAY, False)
				for beats in IN_THE_CLUB_LEFT:
					badge_led_helper.led_single_run_list(beats['pattern'], beats['delay'], False)
		elif button == "RIGHT":
			for i in range(3):
				badge_led_helper.led_single_run_list(NOTHING, DELAY, False)
				for beats in IN_THE_CLUB_RIGHT:
					badge_led_helper.led_single_run_list(beats['pattern'], beats['delay'], False)
		elif button == "B":
			badge_led_helper.led_single_run_list(NOTHING, DELAY, False)
			for beats in KONAMI:
				badge_led_helper.led_single_run_list(beats['pattern'], beats['delay'], False)
		elif button == "A":
			badge_led_helper.led_single_run_list(NOTHING, DELAY, False)
			for beats in PONG:
				badge_led_helper.led_single_run_list(beats['pattern'], beats['delay'], False)
		elif button == "SELECT":
			GO_HOME_YOURE_DRUNK = True
		elif button == "START":
			GO_HOME_YOURE_DRUNK = True
		else:
			# this really should not happen, so quit just in case
			GO_HOME_YOURE_DRUNK = True
	except Exception as e:
		#print "in_the_club::yo_dj_spin_that_ish(): EXCEPTION"
		#print(e)
		#traceback.print_exc()
		pass
#
#	The main show
#
if __name__ == '__main__':
	global GO_HOME_YOURE_DRUNK

	image_selection = 0
	num_cycles = 1
	#
	# image_selection value given as the first parameter
	# num_cycles value given as the second parameter
	#
	print ""
	if sys.argv[1]:
		try:
			if int(sys.argv[1]) < 0:
				# image_selection is already 0 by initialization
				pass
			elif int(sys.argv[1]) >= len(NUMBER_OF_IMAGES):
				# image_selection number is too high so just use the last one in the dict
				image_selection = len(NUMBER_OF_IMAGES) - 1
			else:
				image_selection = int(sys.argv[1])
		except Exception as e:
			#print "in_the_club::__main__(): EXCEPTION"
			#print(e)
			#traceback.print_exc()
			pass
		if sys.argv[2]:
			try:
				if int(sys.argv[2]) < 1:
					# num_cycles is already 1 by initialization
					pass
				elif int(sys.argv[2]) > MAX_CYCLES:
					# num_cycles number is too high so just use MAX_CYCLES
					num_cycles = MAX_CYCLES
				else:
					num_cycles = int(sys.argv[2])
			except Exception as e:
				#print "in_the_club::__main__(): EXCEPTION"
				#print(e)
				#traceback.print_exc()
				pass
		else:
			print "only one argument given"
	else:
		print "no arguments given"
	try:
		cycle_time_total = NUMBER_OF_IMAGES[image_selection] * SLEEP_TIME * num_cycles
		#	count is used as a backup infinite loop prevention
		count = 0
		current_time = datetime.datetime.now()
		end_time = datetime.datetime.now() + datetime.timedelta(seconds=int(cycle_time_total))
		while (GO_HOME_YOURE_DRUNK == False and current_time < end_time):
			count += 1
			if count > 2400:
				#	2400 = 10 (minutes) * 60 (seconds) / 0.25 (sleep time per loop)
				break
			time.sleep(0.25)
			current_time = datetime.datetime.now()
	except Exception as e:
		#print "in_the_club::__main__(): EXCEPTION"
		#print(e)
		#traceback.print_exc()
		pass
	try:
		badge_led_helper.led_single_run_list(NOTHING, DELAY, False)
	except Exception as e:
		#print "in_the_club::__main__(): EXCEPTION"
		#print(e)
		#traceback.print_exc()
		pass
