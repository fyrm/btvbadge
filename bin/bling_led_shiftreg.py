#!/usr/bin/env python
#================================================
#
#	This program is for SunFounder SuperKit for Rpi.
#
#	Extend use of 8 LED with 74HC595.
#
#	Change the	WhichLeds and sleeptime value under
#	loop() function to change LED mode and speed.
#
#=================================================

import RPi.GPIO as GPIO
import time
import sys

GPIO.setwarnings(False)

SDI   = 11
RCLK  = 22
SRCLK = 13

# Usage: bling_led_shiftreg.py <split|wigwag|flash|cleanup> <sleep time> <animation speed>
# sleep time between led rotation should be around .01 - .05
# bling_led_shiftreg.py split 3 .05

# LEDs correspond to 0 and 1's placement
# 45  00011000 0x18 (LEDs 4 and 5 on)
# 36  00100100 0x24 (LEDs 3 and 6 on)
# 27  01000010 0x42
# 18  10000001 0x81

# 00011000 0x18
# 00111100 0x3C
# 01111110 0x7E
# 11111111 0xFF
# 11100111 0xE7
# 11000011 0xC3
# 10000001 0x81
# 00000000 0x00

if sys.argv[1] == "split":
	LEDS = [0x00,0x18,0x24,0x42,0x81,0x00]	# split

elif sys.argv[1] == "wigwag":
	LEDS = [0x00, 0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01,0x00] # wigwag

elif sys.argv[1] == "flash":
	LEDS = [0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00] # flash

elif sys.argv[1] == "solid":
	LEDS = [0xFF] # solid

elif sys.argv[1] == "matrix":
	LEDS = [0x18,0x3C,0x7E,0xFF,0xE7,0xC3,0x81,0x00] # matrix

elif sys.argv[1] == "upload":
	LEDS = [0x00,0x81,0xC3,0xE7,0xFF,0x7E,0x3C,0x18,0x00] # upload

elif sys.argv[1] == "cleanup":
	LEDS = [0x00] # turn all LEDs off

def setup():
	GPIO.setmode(GPIO.BOARD)    # Number GPIOs by its physical location
	GPIO.setup(SDI, GPIO.OUT)
	GPIO.setup(RCLK, GPIO.OUT)
	GPIO.setup(SRCLK, GPIO.OUT)
	GPIO.output(SDI, GPIO.LOW)
	GPIO.output(RCLK, GPIO.LOW)
	GPIO.output(SRCLK, GPIO.LOW)

def hc595_in(dat):
	for bit in range(0, 8):	
		GPIO.output(SDI, 0x80 & (dat << bit))
		GPIO.output(SRCLK, GPIO.HIGH)
		time.sleep(0.001)
		GPIO.output(SRCLK, GPIO.LOW)

def hc595_out():
	GPIO.output(RCLK, GPIO.HIGH)
	time.sleep(0.001)
	GPIO.output(RCLK, GPIO.LOW)

def loop():
	#sleeptime = 0.01	# Change speed, lower value, faster speed
	sleeptime = float(sys.argv[3]) 	# Change speed, lower value, faster speed
	while True:

		for i in range(0, len(LEDS)):
			hc595_in(LEDS[i])
			hc595_out()
			time.sleep(sleeptime)
		
		time.sleep(float(sys.argv[2]))

def destroy():   # When program ending, the function is executed. 
	GPIO.cleanup()

if __name__ == '__main__': # Program starting from here 
	setup() 

	if sys.argv[1] == "cleanup":
		hc595_in(LEDS[0])
		hc595_out()
 		GPIO.output(SDI, GPIO.LOW)
		GPIO.output(RCLK, GPIO.LOW)
		GPIO.output(SRCLK, GPIO.LOW)
		sys.exit()

	try:
		loop()  
	except KeyboardInterrupt:  
 		GPIO.output(SDI, GPIO.LOW)
		GPIO.output(RCLK, GPIO.LOW)
		GPIO.output(SRCLK, GPIO.LOW)
		destroy()  
