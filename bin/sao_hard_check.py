#!/usr/bin/python

import RPi.GPIO as GPIO
import sys

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)

state = GPIO.input(22)
if state:
	print('turning off')
	GPIO.output(22, 0)
else:
	print('turning on')
	GPIO.output(22, 1)

if (GPIO.input(2)==GPIO.LOW):
	print "2 is low"
else:
	print "2 is high"
