#!/usr/bin/env python
'''
cymon.py
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
#from __future__ import print_function

#
#	GLOBAL VARIABLES
#
#
global buttons_pressed
buttons_pressed = []
global I_DONT_WANT_TO_PLAY_ANY_MORE
I_DONT_WANT_TO_PLAY_ANY_MORE = False
global WAIT_FOR_ME
WAIT_FOR_ME = True
SAVE_FILE = "/badge/addons/what_did_cymon_say"
#	LED lighting
LED_DOWN = "18"
LED_UP = "45"
LED_LEFT = "67"
LED_RIGHT = "23"
PATTERN_LIST = ["U", "D", "L", "R"]
NOTHING = "0"
#	Delays for LEDs to be activated (higher delay for lower levels)
DELAY_MIN = 0.05
DELAY_MAX = 0.5
DELAY_CHANGE_PER_LEVEL = 0.05
#	Other
TIME_BASE = 4
TIME_PER_LEVEL = 4
TIME_TICK = 0.25
PATTERNS_BASE = 2
PATTERNS_PER_LEVEL = 2
POINTS_PER_LEVEL_BASE = 10
POINTS_PER_LEVEL_MULTIPLIER = 1.25
ATTEMPTS_MAX = 3
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
	global buttons_pressed
	global I_DONT_WANT_TO_PLAY_ANY_MORE
	
	if channel == 19:
		#print("19 - A")
 		time.sleep(.01)
	elif channel == 26:
		#print("26 - START")
		time.sleep(.01)
	elif channel == 20:
		#print("20 - SELECT")
		subprocess.call(['/badge/bin/badge_display_pwm.sh'], shell=False)
		time.sleep(.01)
	elif channel == 13:
		#print("13 - UP")
		buttons_pressed.append("U")
		time.sleep(.01)
	elif channel == 6:
		#print("6 - B")
		time.sleep(.01)
	elif channel == 21:
		#print("21 - LEFT")
		buttons_pressed.append("L")
		time.sleep(.01)
	elif channel == 16:
		#print("16 - DOWN")
		buttons_pressed.append("D")
		time.sleep(.01)
	elif channel == 12:
		#print("12 - RIGHT")
		buttons_pressed.append("R")
		time.sleep(.01)
	elif channel == 3:
		#print("3 - POWER")
		I_DONT_WANT_TO_PLAY_ANY_MORE = True
		time.sleep(.01)
	elif channel == 5:
		#print("5 - POWER")
		I_DONT_WANT_TO_PLAY_ANY_MORE = True
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
#	Other functions
#
def generate_pattern(level):
	try:
		retval = []
		for i in range(PATTERNS_BASE):
			retval.append(PATTERN_LIST[random.randint(0,3)])
		for i in range(level):
			for j in range(PATTERNS_PER_LEVEL):
				retval.append(PATTERN_LIST[random.randint(0,3)])
				#time.sleep(0.01)
			#	shuffle PATTERN_LIST to help with randomness
			temp = PATTERN_LIST[0]
			for j in range(len(PATTERN_LIST) - 1):
				PATTERN_LIST[j] = PATTERN_LIST[j + 1]
			PATTERN_LIST[-1] = temp
		return retval
	except Exception as e:
		print "cymon::generate_pattern(): EXCEPTION"
		print(e)
		traceback.print_exc()
#
def display_pattern(pattern, delay):
	global WAIT_FOR_ME
	try:
		led_pattern = []
		for p in pattern:
			if p == "U":
				led_pattern.append(LED_UP)
			elif p == "D":
				led_pattern.append(LED_DOWN)
			elif p == "L":
				led_pattern.append(LED_LEFT)
			elif p == "R":
				led_pattern.append(LED_RIGHT)
			led_pattern.append(NOTHING)
		badge_led_helper.led_single_run_list(led_pattern, delay, False)
		WAIT_FOR_ME = False
	except Exception as e:
		print "cymon::display_pattern(): EXCEPTION"
		print(e)
		traceback.print_exc()
#
def update_screen(message, countdown=False):
	try:
		subprocess.call(['clear'], shell=False)
		subprocess.call(['printf', message], shell=False)
		time.sleep(2)
		if countdown == True:
			subprocess.call(['clear'], shell=False)
			subprocess.call(['figlet', '-w 40 -c -f letter', '3'], shell=False)
			time.sleep(1)
			subprocess.call(['clear'], shell=False)
			subprocess.call(['figlet', '-w 40 -c -f letter', '2'], shell=False)
			time.sleep(1)
			subprocess.call(['clear'], shell=False)
			subprocess.call(['figlet', '-w 40 -c -f letter', '1'], shell=False)
			time.sleep(1)
			subprocess.call(['clear'], shell=False)
			subprocess.call(['figlet', '-w 40 -c -f letter', 'GO!'], shell=False)
		return
	except Exception as e:
		print "cymon::update_screen(): EXCEPTION"
		print(e)
		traceback.print_exc()
#
#	The main show
#
if __name__ == '__main__':
	global I_DONT_WANT_TO_PLAY_ANY_MORE
	global buttons_pressed
	global WAIT_FOR_ME
	#	get stuff from save file
	try:
		high_score = 0
		high_level = 0
		with open(SAVE_FILE, "r") as savefile:
			content = savefile.read().splitlines()
			for line in content:
				if line.startswith("high_score"):
					line_split = line.split()
					try:
						high_score = float(line_split[1].strip())
					except:
						print "failed to get high_score from file"
				elif line.startswith("high_level"):
					line_split = line.split()
					try:
						high_level = int(line_split[1].strip())
					except:
						print "failed to get high_level from file"
		#	initiate variables so that they hit their starting point in first loop of while
		points = 0
		level = 0
		level_passed = True
		delay = DELAY_MAX + DELAY_CHANGE_PER_LEVEL
		#	the aforementioned while:
		while (I_DONT_WANT_TO_PLAY_ANY_MORE == False and level_passed == True):
			level += 1
			level_passed = False
			delay -= DELAY_CHANGE_PER_LEVEL
			if delay < DELAY_MIN:
				delay = DELAY_MIN
			buttons_pressed = []
			attempts = 1
			pattern = []
			pattern = generate_pattern(level)
			#	while loop to allow multiple attempts
			while (I_DONT_WANT_TO_PLAY_ANY_MORE == False and level_passed == False and attempts <= ATTEMPTS_MAX):
				update_screen("\nWatch the lights...\n", True)
				WAIT_FOR_ME = True
				display_pattern(pattern, delay)
				while WAIT_FOR_ME == True:
					time.sleep(TIME_TICK)
				WAIT_FOR_ME == True
				update_screen("\nNow press the buttons \nin the correct order!\n\n", False)
				#	allow time for player to press buttons
				time_to_play = (TIME_BASE + (level * TIME_PER_LEVEL)) / TIME_TICK
				tick = 0
				while (I_DONT_WANT_TO_PLAY_ANY_MORE == False and tick < time_to_play):
					
					if len(buttons_pressed) >= (len(pattern)):
						#	break after player hits enough buttons
						break
					time.sleep(TIME_TICK)
					tick = tick + 1
					
				#	check if player hit the correct buttons and proceed accordingly
				if buttons_pressed == pattern:
					print "Correct! Nicely done."
					level_passed = True
					points = (points * POINTS_PER_LEVEL_MULTIPLIER) + (POINTS_PER_LEVEL_BASE * level / attempts)
					time.sleep(2)
				else:
					msg = "That was not correct.\n"
					attempts += 1
					buttons_pressed = []
					if attempts < ATTEMPTS_MAX:
						msg += "Try again!\n"
					elif attempts == ATTEMPTS_MAX:
						msg += "One more attempt...\n"
					else:
						msg += "That was your last attempt.\n"
						level -= 1
					print msg
					buttons_pressed = []
					time.sleep(2)
		#	update SAVE_FILE
		if points > high_score:
			high_score = points
			print "Congratulations on the new high score!\n"
		if level > high_level:
			high_level = level
			print "Congratulations on the new highest level completed!\n"
		with open(SAVE_FILE, "w") as savefile:
			savefile.write("cymon stats\n")
			savefile.write("high_score: " + str(high_score) + "\n")
			savefile.write("high_level: " + str(high_level) + "\n")
		time.sleep(2)
	except Exception as e:
		print "cymon::__main__(): EXCEPTION"
		print(e)
		traceback.print_exc()
