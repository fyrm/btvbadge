#!/usr/bin/python

import RPi.GPIO as GPIO
import time
import signal
import sys
import subprocess
import hashlib

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

global press
press=""

def interrupt_handler(channel):
	global press

	if channel == 19:
		#print("19 - A")
		press+="A"
 		time.sleep(.01)
	elif channel == 26:
		#print("26 - START")
		press+="S"
		subprocess.call(['systemctl', 'restart', 'getty@tty1.service'], shell=False)
		time.sleep(.01)
	elif channel == 20:
		#print("20 - SELECT")
		subprocess.call(['/badge/bin/badge_display_pwm.sh'], shell=False)
		time.sleep(.01)
	elif channel == 13:
		#print("13 - UP")
		press+='U'
		time.sleep(.01)
	elif channel == 6:
		#print("6 - B")
		press+="B"
		time.sleep(.01)
	elif channel == 21:
		#print("21 - LEFT")
		press+="L"
		time.sleep(.01)
	elif channel == 16:
		#print("16 - DOWN")
		press+="D"
		time.sleep(.01)
	elif channel == 12:
		#print("12 - RIGHT")
		press+="R"
		time.sleep(.01)
	elif channel == 3:
		#print("3 - POWER")
		time.sleep(.01)
		#subprocess.call(['shutdown', '-h', 'now'], shell=False)
	elif channel == 5:
		#print("5 - POWER")
		time.sleep(.01)
		#subprocess.call(['shutdown', '-h', 'now'], shell=False)

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


tick = 0
while (tick < 20):
	time.sleep(.25)
	tick = tick + 1

# welcome.  this should get you started :)
salt = 'XstblibaQNaAWO8dYo:'
codes = {
		'50f9d9597642a0d090d4a613bf81f9d8bc4c7b4ec1db48c9f4abf88225c3cfad' : 'konami',
		'b3a218481d173dcd066a42eb74702714c5bf7f0c77982666c703f0d2b78b4a35' : 'admin',
		'fda91114369fdd643f5ab0c12a808dfbc0d360a1eb2fd3d9a56e66220d000313' : 'debug',
		'df722c019cb312748828b3b547d685448e43092e65d78eae2999d39bd96052b3' : 'moonbuggy',
		'3a868834d0e8d1690020d9fd01793df75496a127d7e82dab8dece423ee0bad5f' : 'netris',
		'4217654752e9fc77c61d54247057b97448506bf8e32eb9494d6c99166b5685d8' : 'da',
		'1d5420fdff3a2529e89edc307eba788c9b177d8482d49e4f05a3bd71fadf2444' : 'easy', 
		'b62d9205a693b3601ade197944cd39f305c6388dd1b97cff1190b5b7e6801077' : 'medium', 
		'8c30f3cdcf02ec6e0fc8e97f12738be7e2b2f710f5888932da5163a8891f75ea' : 'hard', 
		'f2664042ea3d51d5b94f49c36d5d9892eb9b913fd306b9648e1fd5dcd848932f' : 'expert', 
	}

hashed = hashlib.sha256(salt + press.encode()).hexdigest()

for item in codes:
	if hashed in codes:
		passphrase = salt + press
		addone = '/badge/addons/' + codes[hashed] + '.sh.asc'
		addond = '/badge/data/unlocks/' + codes[hashed] + '.sh'
		
		cmd = '/usr/bin/gpg -q --batch --passphrase ' + passphrase + ' ' + '-d ' + addone + ' > ' + addond
		
		subprocess.Popen([cmd], shell=True)
		
		cmd = 'chmod +x ' + addond
		subprocess.Popen([cmd], shell=True)


		print codes[hashed] + ' unlocked!'
		time.sleep(1)
		break
