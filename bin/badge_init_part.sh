#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

# badge_init_part.sh
# if /badge/data (partition 3) doesn't exist, create it
# if it exists, delete it, then recreate it

source /badge/bin/badge_vars.sh

part=$(fdisk -l /dev/mmcblk0 | grep mmcblk0p3)
if [[ $part =~ mmcblk0p3 ]]; then
	echo "umounting /badge/data"
	fuser -k -9 /badge/data
	umount /badge/data/
	echo "removing partition 3"
	sync
	echo -e "d\n3\nw\n" | fdisk /dev/mmcblk0 > /dev/null 2>&1
	partprobe /dev/mmcblk0
else
	echo "data partition not present"
fi

echo "creating data partition"
echo -e "n\np\n3\n6399591\n\nw\n" | fdisk /dev/mmcblk0 > /dev/null 2>&1
partprobe /dev/mmcblk0
echo "DO NOT POWER OFF"
mkfs.ext4 -F -q /dev/mmcblk0p3 >/dev/null 2>&1
echo "backing up"
cp /etc/fstab /etc/fstab.bak
echo "finalizing"
blkid=$(blkid /dev/mmcblk0p3 | sed 's/[="]/ /g' | awk '{print $7}')

if grep -q "$blkid" /etc/fstab; then
	echo "blkid $blkid already exists"
else
	echo "adding $blkid"
	echo "PARTUUID=$blkid  /badge/data               ext4    defaults,noatime  0       1" >> /etc/fstab
fi

mkdir -p /badge/data
mount /badge/data

mkdir -p $DATA_MSGS
echo "Hello new badgeower and welcome.  You'll see announcements (some important) from the Blue Team Village here.  Leaving badgenet will prevent receipt of messages.  Generally, these messages will be broadcast in the village." > $DATA_MSGS/NEW_welcome.txt

echo "all done, rebooting.."
sleep 2
shutdown -r now
