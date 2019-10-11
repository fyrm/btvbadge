#!/bin/bash

source /badge/bin/badge_vars.sh

clear

systemctl stop badge_button_handler_main_menu
python -W ignore /badge/addons/gob.py &
wait
systemctl start badge_button_handler_main_menu

clear
printf "\nI've made a huge mistake.\n"
tput sgr0
sleep 1

