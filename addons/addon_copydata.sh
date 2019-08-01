#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

# copies any add-ons from external SD card reader connected using USB OTG cable attached to RPI's USB data port
# requires one single partition containing the following structure:
# /badge/data/roms
# /badge/addons/
# /badge/art/
# SD card must show up as /dev/sda

source /badge/bin/badge_vars.sh

addon_help="This addon copies addons, art or roms from USB storage device attached to RPI's data port, eg. micro SD card reader.  FS on SD card must be W95 FAT32, ext2/3/4 or other mountable by default.  Addon copies all files in these dirs on the external device: /badge/addons/*, /badge/data/roms/*, /badge/art/*.  For help on addons and art, see help menu."

dialog --begin 4 0 --no-lines --no-collapse --infobox "$addon_help" 13 40 \
	--and-widget --begin 0 9 --no-collapse --title "DATA COPY" --no-tags --defaultno --yes-button "yes" --no-button "NO"  --yesno "proceed with copy?" 5 22

ret=$?
case "$ret" in
	0) ;; # yes
	1) clear;exit ;; # no
	*) exit ;;
esac

parts=$(fdisk -l /dev/sda | egrep "^\/dev\/sda" | awk '{print $1}')

if [[ $parts =~ /dev/sda1 ]]; then
	mkdir -p /mnt/sd
	mount /dev/sda1 /mnt/sd
	if grep -qs '/mnt/sd ' /proc/mounts; then
		echo "mounted"
	else
		dialog --begin 0 3 --title "DATA COPY" --msgbox "could not mount $parts" 5 33
		exit
	fi
else
	dialog --begin 0 3 --title "DATA COPY" --msgbox "no available devices, exiting" 5 33
	clear
	exit
fi

function copy_data {
	cp /mnt/sd/badge/addons/* /badge/addons/
	chmod +rx /badge/addons/*.sh
	cp /mnt/sd/badge/art/* /badge/art/
	chmod 666 /badge/art/*
	cp /mnt/sd/badge/data/roms/* /badge/data/roms/
	chmod 444 /badge/data/roms/*
	dialog --begin 0 11 --no-collapse --title "DATA COPY" --no-tags --msgbox "copy complete" 5 17
	clear
}

dialog --begin 0 8 --no-collapse --title "DATA COPY" --no-tags --defaultno --yes-button "yes" --no-button "NO"  --yesno "copy contents of $parts to /badge/addons, /badge/art, /badge/data/roms?" 9 21

ret=$?
case "$ret" in
	0) copy_data;umount $parts ;; # yes
	1) clear;exit ;; # no
	*) exit ;;
esac
