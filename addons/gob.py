#!/usr/bin/env python
'''
gob.py
'''
import sys
sys.path.append('/badge/bin/badge_led_helper')
import badge_led_helper
import glob
import RPi.GPIO as GPIO
import time
import uinput
import signal
import os
import traceback

#
#	GLOBAL VARIABLES
#
ADDON_DIR = "/badge/addons/"
PSEUDO_GIF_DIR = "gob_565/"
#
#	run until this is set to True
global COUNTDOWN_FINISHED
#
#	variables to determine how long this script should run
SLEEP_TIME = 0.04
MAX_CYCLES = 100
#NUMBER_OF_IMAGES = {0:101}

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
	global COUNTDOWN_FINISHED
	
	COUNTDOWN_FINISHED = True

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
#	Functions
#
def open_images():
	all_images = []
	try:
		image_filenames = glob.glob(ADDON_DIR + PSEUDO_GIF_DIR + "*.565")
		image_filenames.sort()
		for filename in image_filenames:
			try:
				img = open(filename, "rb")
				f = img.read()
				img_bytes = bytearray(f)
				all_images.append(img_bytes)
			except Exception as e:
				#print("gob::open_images(): EXCEPTION")
				#print(e)
				#traceback.print_exc()
				pass
		return all_images
	except Exception as e:
		#print("gob::open_images(): EXCEPTION")
		#print(e)
		#traceback.print_exc()
		pass
#
#	The main show
#
if __name__ == '__main__':
	global COUNTDOWN_FINISHED

	COUNTDOWN_FINISHED = False
	all_images = []

	try:
		all_images = open_images()
		for cycle_num in range(MAX_CYCLES):
			for img_bytes in all_images:
				try:
					fb = os.open("/dev/fb1", os.O_RDWR)
					numbytes = os.write(fb, img_bytes)
					os.close(fb)
				except Exception as e:
					#print("gob::__main__(): EXCEPTION")
					#print(e)
					#traceback.print_exc()
					pass
				if COUNTDOWN_FINISHED == True:
					break
				time.sleep(SLEEP_TIME)
			if COUNTDOWN_FINISHED == True:
				break
	except Exception as e:
		#print("gob::__main__(): EXCEPTION")
		#print(e)
		#traceback.print_exc()
		pass
