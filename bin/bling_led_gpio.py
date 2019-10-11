#!/usr/bin/python

import RPi.GPIO as GPIO ## Import GPIO library
import time ## Import 'time' library. Allows us to use 'sleep'
import sys

#LED1 = pin 11, BCM 17, GPIO 17
#LED2 = pin 13, BCM 27, GPIO 27
#LED3 = pin 15, BCM 22, GPIO 22
#LED4 = pin 21, BCM 9, GPIO 9
#LED5 = pin 22, BCM 25, GPIO 25
#LED6 = pin 26, BCM 7, GPIO 7
#LED7 = pin 29, BCM 5, GPIO 5
#LED8 = pin 7, BCM 4, GPIO 4


GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(11, GPIO.OUT)
GPIO.setup(13, GPIO.OUT)
GPIO.setup(15, GPIO.OUT)
GPIO.setup(21, GPIO.OUT)
GPIO.setup(22, GPIO.OUT)
GPIO.setup(26, GPIO.OUT)
GPIO.setup(29, GPIO.OUT)
GPIO.setup(7, GPIO.OUT)

def loop():
	sleeptime = 0.05  # Change speed, lower value, faster speed
	while True:
		GPIO.output(11,True)
		GPIO.output(13,True)
		GPIO.output(15,True)
		GPIO.output(21,True)
		GPIO.output(22,True)
		GPIO.output(26,True)
		GPIO.output(29,True)
		GPIO.output(7,True)
   
	time.sleep(int(sys.argv[2]))

def destroy():   # When program ending, the function is executed.
  GPIO.cleanup()

if __name__ == '__main__': # Program starting from here

	if sys.argv[1] == "cleanup":
		GPIO.setwarnings(False)
		GPIO.output(11,False)
		GPIO.output(13,False)
		GPIO.output(15,False)
		GPIO.output(21,False)
		GPIO.output(22,False)
		GPIO.output(26,False)
		GPIO.output(29,False)
		GPIO.output(7,False)
		GPIO.setup(11, GPIO.LOW)
		GPIO.setup(13, GPIO.LOW)
		GPIO.setup(15, GPIO.LOW)
		GPIO.setup(21, GPIO.LOW)
		GPIO.setup(22, GPIO.LOW)
		GPIO.setup(26, GPIO.LOW)
		GPIO.setup(29, GPIO.LOW)
		GPIO.setup(7, GPIO.LOW)
		sys.exit()

	try:
		loop()
	except KeyboardInterrupt:
		GPIO.setwarnings(False)
		GPIO.output(11,False)
		GPIO.output(13,False)
		GPIO.output(15,False)
		GPIO.output(21,False)
		GPIO.output(22,False)
		GPIO.output(26,False)
		GPIO.output(29,False)
		GPIO.output(7,False)
		GPIO.setup(11, GPIO.LOW)
		GPIO.setup(13, GPIO.LOW)
		GPIO.setup(15, GPIO.LOW)
		GPIO.setup(21, GPIO.LOW)
		GPIO.setup(22, GPIO.LOW)
		GPIO.setup(26, GPIO.LOW)
		GPIO.setup(29, GPIO.LOW)
		GPIO.setup(7, GPIO.LOW)

		destroy()
