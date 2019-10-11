#!/usr/bin/python

import RPi.GPIO as GPIO
import time
import uinput
import signal
import sys
import subprocess

device = uinput.Device([
	uinput.KEY_UP,
	uinput.KEY_DOWN,
	uinput.KEY_LEFT,
	uinput.KEY_RIGHT,
	uinput.KEY_TAB,
	uinput.KEY_ENTER,
])

#    UP = pin 33, BCM 13
#  DOWN = pin 36, BCM 16
#  LEFT = pin 40, BCM 21
# RIGHT = pin 32, BCM 12
#     A = pin 35, BCM 19
#     B = pin 31, BCM 6
# START = pin 37, BCM 26
#SELECT = pin 38, BCM 20
# POWER = pin  5, BCM 3

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(26, GPIO.IN, pull_up_down=GPIO.PUD_UP) # START
GPIO.setup(19, GPIO.IN, pull_up_down=GPIO.PUD_UP) # A
GPIO.setup(13, GPIO.IN, pull_up_down=GPIO.PUD_UP) # UP
GPIO.setup(6, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # B
#GPIO.setup(3, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # POWER
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
	if channel == 19:
		#print("19 - A")
		device.emit_click(uinput.KEY_TAB)
 		time.sleep(.01)
	elif channel == 26:
		#print("26 - START")
		cmd = 'pkill -9 -f -x "/bin/bash /badge/bin/menu_main.sh"'
		subprocess.Popen([cmd], shell=True)
		time.sleep(.01)
	elif channel == 20:
		#print("20 - SELECT")
		subprocess.call(['/badge/bin/badge_display_pwm.sh'], shell=False)
		time.sleep(.01)
	elif channel == 13:
		#print("13 - UP")
		device.emit_click(uinput.KEY_UP)
		time.sleep(.01)
	elif channel == 6:
		#print("6 - B")
		device.emit_click(uinput.KEY_ENTER)
		time.sleep(.01)
	elif channel == 21:
		#print("21 - LEFT")
		device.emit_click(uinput.KEY_LEFT)
		time.sleep(.01)
	elif channel == 16:
		#print("16 - DOWN")
		device.emit_click(uinput.KEY_DOWN)
		time.sleep(.01)
	elif channel == 12:
		#print("12 - RIGHT")
		device.emit_click(uinput.KEY_RIGHT)
		time.sleep(.01)
	# ENABLE IF USING MODULAR VERSION
	#elif channel == 3:
		#print("3 - POWER")
		#time.sleep(.01)
		#subprocess.call(['shutdown', '-h', 'now'], shell=False)
	elif channel == 5:
		cmd = '/badge/bin/shutdown.sh'
		subprocess.Popen([cmd], shell=True)
		#print("5 - POWER")
		#time.sleep(.01)
		#subprocess.call(['shutdown', '-h', 'now'], shell=False)


# 200 original value
GPIO.add_event_detect(26, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(19, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(13, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(6, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
#GPIO.add_event_detect(3, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(21, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(16, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(12, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(20, GPIO.RISING, callback=interrupt_handler, bouncetime=200)
GPIO.add_event_detect(5, GPIO.RISING, callback=interrupt_handler, bouncetime=200)

while (True):
	time.sleep(.3)
	#time.sleep(.25)
