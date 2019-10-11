#!/usr/bin/python3
'''
in_the_club_screen.py
'''
import sys
import time
import os
import traceback
import glob
import RPi.GPIO as GPIO
import uinput
import signal

#
#	GLOBAL VARIABLES
#
#	directories containing the pseudo-gifs
ADDON_DIR = "/badge/addons/"
PSEUDO_GIF_DIRS = {0:"equalizer_ring_565/", 1:"equalizer_background_565/", 2:"equalizer_standard_565/", 3:"equalizer_square_565/"}
SLEEP_TIME = 0.04
MAX_CYCLES = 100
#
#	run until this is set to True
global GO_HOME_YOURE_DRUNK

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
	
	if channel == 26:
		#print("26 - START")
		GO_HOME_YOURE_DRUNK = True
		time.sleep(.01)
	elif channel == 20:
		#print("20 - SELECT")
		GO_HOME_YOURE_DRUNK = True
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
#	Functions
#
def open_images(image_selection):
	all_images = []
	try:
		image_filenames = glob.glob(ADDON_DIR + PSEUDO_GIF_DIRS[image_selection] + "*.565")
		image_filenames.sort()
		for filename in image_filenames:
			try:
				img = open(filename, "rb")
				f = img.read()
				img_bytes = bytearray(f)
				all_images.append(img_bytes)
			except Exception as e:
				print("in_the_club_screen::open_images(): EXCEPTION")
				print(e)
				traceback.print_exc()
				pass
		return all_images
	except Exception as e:
		print("in_the_club_screen::open_images(): EXCEPTION")
		print(e)
		traceback.print_exc()
		#pass

#
#	The main show
#
if __name__ == '__main__':
	global GO_HOME_YOURE_DRUNK
	GO_HOME_YOURE_DRUNK = False
	
	image_selection = 0
	num_cycles = 1
	all_images = []
	#
	# image_selection value given as the first parameter
	# num_cycles value given as the second parameter
	#
	if sys.argv[1]:
		try:
			if int(sys.argv[1]) < 0:
				# image_selection is already 0 by initialization
				pass
			elif int(sys.argv[1]) >= len(PSEUDO_GIF_DIRS):
				# image_selection number is too high so just use the last one in the dict
				image_selection = len(PSEUDO_GIF_DIRS) - 1
			else:
				image_selection = int(sys.argv[1])
		except Exception as e:
			print("in_the_club_screen::__main__(): EXCEPTION")
			print(e)
			traceback.print_exc()
			#pass
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
				print("in_the_club_screen::__main__(): EXCEPTION")
				print(e)
				traceback.print_exc()
				#pass
	try:
		all_images = open_images(image_selection)
		for cycle_num in range(num_cycles):
			for img_bytes in all_images:
				try:
					fb = os.open("/dev/fb1", os.O_RDWR)
					numbytes = os.write(fb, img_bytes)
					os.close(fb)
				except Exception as e:
					print("in_the_club_screen::__main__(): EXCEPTION")
					print(e)
					traceback.print_exc()
					#pass
				if GO_HOME_YOURE_DRUNK == True:
					break
				time.sleep(SLEEP_TIME)
			if GO_HOME_YOURE_DRUNK == True:
				break
	except Exception as e:
		print("in_the_club_screen::__main__(): EXCEPTION")
		print(e)
		traceback.print_exc()
		#pass
