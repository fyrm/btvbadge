#!/usr/bin/python

#LED1 = pin 11, BCM 17, GPIO 17
#LED2 = pin 13, BCM 27, GPIO 27
#LED3 = pin 15, BCM 22, GPIO 22
#LED4 = pin 21, BCM 9, GPIO 9
#LED5 = pin 22, BCM 25, GPIO 25
#LED6 = pin 26, BCM 7, GPIO 7
#LED7 = pin 29, BCM 5, GPIO 5
#LED8 = pin 7, BCM 4, GPIO 4

import RPi.GPIO as GPIO
import time
LedPin = 7 # pin11
def setup():
	GPIO.setmode(GPIO.BOARD) # Numbers GPIOs by physical location
	GPIO.setup(LedPin, GPIO.OUT) # Set LedPin's mode is output
	GPIO.output(LedPin, GPIO.HIGH) # Set LedPin high(+3.3V) to turn on led

def blink():
	while True:
		GPIO.output(LedPin, GPIO.HIGH) # led on
		time.sleep(1)
		GPIO.output(LedPin, GPIO.LOW) # led off
		time.sleep(1)

def destroy():
	GPIO.output(LedPin, GPIO.LOW) # led off
	GPIO.cleanup() # Release resource
