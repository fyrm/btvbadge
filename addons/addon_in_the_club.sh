#!/bin/bash

source /badge/bin/badge_vars.sh

clear
printf "\nPress different buttons to \nenable different LED patterns."
sleep 1
printf "\n\nUse SCRN, or MENU buttons to quit."
sleep 1
printf "\n\nNot the PWR button though."
sleep 1
printf "\n\nJust in case."
sleep 1
clear

# image_selection and num_cycles values
image_selection=$(shuf -i 0-3 -n 1)
num_cycles=$(shuf -i 5-10 -n 1)

systemctl stop badge_button_handler_main_menu
python -W ignore /badge/addons/in_the_club_screen.py $image_selection $num_cycles &
python -W ignore /badge/addons/in_the_club.py $image_selection $num_cycles &
wait
python /badge/bin/bling_led_shiftreg.py cleanup &
wait
systemctl start badge_button_handler_main_menu

clear
printf "\nLeaving the club.\n\nDon't forget to drink some water!\n"
tput sgr0
sleep 3

