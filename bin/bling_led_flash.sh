#!/bin/bash

/badge/bin/bling_stop_led.sh  
nohup /badge/bin/bling_led_shiftreg.py matrix 3 .05 >/dev/null 2>&1 & 
