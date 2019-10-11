#!/usr/bin/env python
'''
badge_led_helper.py
'''
import sys
import traceback
import re
import argparse
import RPi.GPIO as GPIO
import time

GPIO.setwarnings(False)

'''
SDI   = 11
RCLK  = 22
SRCLK = 13
PIN 11 (SRCLK) = pin 13, BCM27
PIN 12 (RCLK) = pin 22, BCM25
PIN 14 (SDI) = pin 11, BCM 17
'''
SDI_BCM = 17
RCLK_BCM = 25
SRCLK_BCM = 27

LED_NUMBER_MIN = 1
LED_NUMBER_MAX = 8
LED_RIGHT_LOWER = "1"
LED_RIGHT_MIDDLE_LOWER = "2"
LED_RIGHT_MIDDLE_UPPER = "3"
LED_RIGHT_UPPER = "4"
LED_LEFT_UPPER = "5"
LED_LEFT_MIDDLE_UPPER = "6"
LED_LEFT_MIDDLE_LOWER = "7"
LED_LEFT_LOWER = "8"

DEFAULT_DELIMETER = '-'

#
#
#	Functions for basic LED functionality (copied from blind_led_shiftreg.py)
#
#
def setup():
	'''
	GPIO.setmode(GPIO.BOARD)    # Number GPIOs by its physical location
	GPIO.setup(SDI, GPIO.OUT)
	GPIO.setup(RCLK, GPIO.OUT)
	GPIO.setup(SRCLK, GPIO.OUT)
	GPIO.output(SDI, GPIO.LOW)
	GPIO.output(RCLK, GPIO.LOW)
	GPIO.output(SRCLK, GPIO.LOW)
	'''
	GPIO.setmode(GPIO.BCM)
	GPIO.setup(SDI_BCM, GPIO.OUT)
	GPIO.setup(RCLK_BCM, GPIO.OUT)
	GPIO.setup(SRCLK_BCM, GPIO.OUT)
	GPIO.output(SDI_BCM, GPIO.LOW)
	GPIO.output(RCLK_BCM, GPIO.LOW)
	GPIO.output(SRCLK_BCM, GPIO.LOW)



def hc595_in(dat):
	for bit in range(0, 8):	
		GPIO.output(SDI_BCM, 0x80 & (dat << bit))
		GPIO.output(SRCLK_BCM, GPIO.HIGH)
		time.sleep(0.001)
		GPIO.output(SRCLK_BCM, GPIO.LOW)

def hc595_out():
	GPIO.output(RCLK_BCM, GPIO.HIGH)
	time.sleep(0.001)
	GPIO.output(RCLK_BCM, GPIO.LOW)

#
#
#	Functions for interface to basic LED functionality
#
#

#
#	led_single_run
#
#		Runs a single execution of lighting up the given LEDs (by number string) and then dies
#
def led_single_run(led_numbers="0", time_on=0.05):
	try:
		setup()
		LEDS = ["0x00"]
		LEDS.append(convert_led_numbers_to_hex_single(led_numbers))
		LEDS.append("0x00")
		for led_num in LEDS:
			hc595_in(int(led_num, 16))
			hc595_out()
			time.sleep(time_on)
 		GPIO.output(SDI_BCM, GPIO.LOW)
		GPIO.output(RCLK_BCM, GPIO.LOW)
		GPIO.output(SRCLK_BCM, GPIO.LOW)
	except Exception as e:
		print("led_single_run: EXCEPTION")
		print(e)
		traceback.print_exc()
		return

#
#	led_single_run_string
#
#		Runs a single execution of lighting up the given LEDs (by number string) and then dies
#
def led_single_run_string(led_numbers="0", delimeter='-', time_on=0.05, leds_off_at_delimeter=False):
	try:
		setup()
		LEDS = ["0x00"]
		LEDS.append(convert_led_numbers_to_hex_multiple(led_numbers, delimeter, leds_off_at_delimeter))
		if LEDS[-1] != "0x00":
			LEDS.append("0x00")
		for led_num in LEDS:
			hc595_in(int(led_num, 16))
			hc595_out()
			time.sleep(time_on)
 		GPIO.output(SDI_BCM, GPIO.LOW)
		GPIO.output(RCLK_BCM, GPIO.LOW)
		GPIO.output(SRCLK_BCM, GPIO.LOW)
	except Exception as e:
		print("led_single_run: EXCEPTION")
		print(e)
		traceback.print_exc()
		return

#
#	led_single_run_list
#
#		Runs a single execution of lighting up the given LEDs (by list of number strings) and then dies
#
def led_single_run_list(led_number_list, time_on=0.05, leds_off_at_delimeter=False):
	try:
		setup()
		LEDS = ["0x00"]
		led_hex_strings_list = convert_led_numbers_to_hex_list(led_number_list, leds_off_at_delimeter)
		for led_hex_string in led_hex_strings_list:
			LEDS.append(led_hex_string)
		if LEDS[-1] != "0x00":
			LEDS.append("0x00")
		for led_num in LEDS:
			hc595_in(int(led_num, 16))
			hc595_out()
			time.sleep(time_on)
 		GPIO.output(SDI_BCM, GPIO.LOW)
		GPIO.output(RCLK_BCM, GPIO.LOW)
		GPIO.output(SRCLK_BCM, GPIO.LOW)
	except Exception as e:
		print("led_single_run: EXCEPTION")
		print(e)
		traceback.print_exc()
		return

#
#	convert_led_numbers_to_hex_single
#
#		Converts a given string of LED numbers (1-8) into the binary on/off string and then returns the hex value equivalent
#		Examples:
#			"4536"
#			"7281"
#
def convert_led_numbers_to_hex_single(led_numbers):
	try:
		retval = ""
		binary_led_onoff = "00000000"
		for i in range(len(led_numbers)):
			led_num = 0
			try:
				led_num = int(led_numbers[i])
			except Exception:
				continue
			if (led_num < LED_NUMBER_MIN or led_num > LED_NUMBER_MAX):
				continue
			index_num = led_num - 1
			binary_led_onoff = binary_led_onoff[:index_num] + "1" + binary_led_onoff[led_num:]
		retval = hex(int(binary_led_onoff, 2))
		return retval
	except Exception as e:
		print("convert_led_numbers_to_hex_single: EXCEPTION")
		print(e)
		traceback.print_exc()
		return 0x00

#
#	convert_led_numbers_to_hex_multiple
#
#		Converts a given set of strings of LED numbers (1-8) into the binary on/off string and then returns a list of the hex value equivalents
#		String sets are separated by a delimeter (default is the '-' character)
#		Examples:
#			"45-36-27-18"
#			"1278|3456|0|3456|1278", "|"
#
def convert_led_numbers_to_hex_multiple(led_number_input, delimeter=DEFAULT_DELIMETER, leds_off_at_delimeter=False):
	retval = []
	try:
		led_number_list = led_number_input.split(delimeter)
		for led_numbers in led_number_list:
			hex_value = convert_led_numbers_to_hex_single(led_numbers)
			retval.append(hex_value)
			if leds_off_at_delimeter == True:
				retval.append("0x00")
		return retval
	except Exception as e:
		print("convert_led_numbers_to_hex_multiple: EXCEPTION")
		print(e)
		traceback.print_exc()
		return retval

#
#	convert_led_numbers_to_hex_list
#
#		Converts a given list of strings of LED numbers (1-8) into the binary on/off string and then returns a list of the hex value equivalents
#		Examples:
#			"45-36-27-18"
#			"1278-3456-0-3456-1278"
#
def convert_led_numbers_to_hex_list(led_number_list, leds_off_at_delimeter=False):
	retval = []
	try:
		for led_numbers in led_number_list:
			hex_value = convert_led_numbers_to_hex_single(led_numbers)
			retval.append(hex_value)
			if leds_off_at_delimeter == True:
				retval.append("0x00")
		return retval
	except Exception as e:
		print("convert_led_numbers_to_hex_list: EXCEPTION")
		print(e)
		traceback.print_exc()
		return retval


#
#	__main__
#
#		basically for testing and troubleshooting
#
if __name__ == '__main__':
	try:
		#led_single_run("15", 0.5)
		led_single_run_list([1, 2, 3, 4, 5, 6, 7, 8], 0.5)
		led_single_run_list([18, 27, 36, 45], 0.5)
		led_single_run_list([45, 3456, 234567, 123678, 1278, 18], 0.25)
		#
		#	simple test calls for converting LED numbers (1-8) into hex number equivalent for which LEDs to turn on
	except Exception as e:
		print("__main__: Exception thrown")
		print(e)
		traceback.print_exc()
