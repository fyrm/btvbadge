#!/bin/bash

clear
tput cup 2 0
printf "Welcome to cymon!\n\n"
printf "Use the D-pad (up/down/left/right) to\n"
printf "match the LED lighting pattern.\n"
printf "You get 2 seconds per level after the\n"
printf "pattern is displayed, plus 4 seconds\n"
printf "to start.\n\n"
printf "Good luck!"
sleep 5
clear
systemctl stop badge_button_handler_main_menu
python /badge/addons/cymon.py
wait
systemctl start badge_button_handler_main_menu
clear
tput cup 2 0
printf "Thanks for playing!"
tput sgr0
sleep 3
