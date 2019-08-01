#!/bin/bash

# put add-on commands here
echo "example add-on that quits after keypress"
echo "- addons are placed in /badge/addons/"
echo "- must use file format addon_name.sh"
echo "- this addon calls another script"
echo "  the other script can do anything"

if [ -t 0 ]; then stty -echo -icanon -icrnl time 0 min 0; fi

clear

# change this
/badge/addons/other_executable.py &

count=0
keypress=''
while [ "x$keypress" = "x" ]; do
  let count+=1
  keypress="`cat -v`"
  sleep 1;
done

# change this (example uses python, can use anything)
pkill -x -f "/usr/bin/python /badge/addons/other_executable.py"

if [ -t 0 ]; then stty sane; fi
clear

