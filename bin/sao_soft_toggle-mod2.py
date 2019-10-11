#!/usr/bin/python

import RPi.GPIO as GPIO
import sys

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(22, GPIO.OUT)

if sys.argv[1] == "on":
	GPIO.setup(22, GPIO.OUT)
	GPIO.output(22, 1)
elif sys.argv[1] == "off":
	GPIO.output(22, 0)
elif sys.argv[1] == "toggle":
	state = GPIO.input(22)
	if state:
		print('SAO power is now off')
		GPIO.output(22, 0)
	else:
		print('SAO power is now on')
		GPIO.output(22, 1)
