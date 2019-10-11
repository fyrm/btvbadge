#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

# This is mostly for items that should be done each boot

source /badge/bin/badge_vars.sh

setfont $FONT_DEFAULT

# prepare shift register in case LEDs still on
$P/bling_led_shiftreg.py cleanup

ln -sf $DRCCYAN $DRC

# configure user handle
if [ ! -f $DATA_HANDLE ]; then
	HANDLE=$($P/mac2name.sh)
	echo "$HANDLE" > $DATA_HANDLE
else
	HANDLE=$(cat $DATA_HANDLE)
fi

### screen brightness
gpio -g mode $PWM_PIN pwm
gpio -g pwm $PWM_PIN $PWM

### set hostname from stored handle, or mac address
if [ -f $DATA_HANDLE ]; then
    hostname=$(cat $DATA_HANDLE)
  else
		hostname=$(cat /sys/class/net/wlan0/address | sed 's/://g')
fi
hostname $hostname
echo $hostname > /etc/hostname

### set avahi hostname
sed -i -e "s/^host-name=.*/host-name=$HANDLE/" /etc/avahi/avahi-daemon.conf


### check if first boot
part=$(fdisk -l /dev/mmcblk0 | grep mmcblk0p3)
if [[ $part =~ mmcblk0p3 ]]; then
	tput setaf 6 > $CONSOLE
	echo "Wake up, $HANDLE.." > $CONSOLE
else
	echo "welcome new badgeowner!" > $CONSOLE
	echo "initializing badge, do not power off" > $CONSOLE
	echo "badge will restart when done" > $CONSOLE
	$P/badge_init_part.sh	> $CONSOLE
fi

if [ ! -f $DATA_BLING_REPEAT ]; then
	echo 3 > $DATA_BLING_REPEAT
else
	BLING_REPEAT=$(cat $DATA_BLING_REPEAT)
fi

DATA_HONEYSSID=/badge/data/honeyssid.txt
# configure 
HONEYSSID="$hostname"
if [ ! -f $DATA_HONEYSSID ]; then
	echo "$HONEYSSID" > $DATA_HONEYSSID
else
	HONEYSSID=$(cat $DATA_HONEYSSID)
fi

# messages folder
mkdir -p $DATA_MSGS

### start badge menu service
systemctl start getty@tty1.service

### setup usb0
### DISABLE BEFORE DEPLOY
USB0=$(printf '192.168.7.%d\n' $(echo `ifconfig wlan0 | grep ether | awk '{print $2}' | cut -d':' -f6 | sed 's/://g'` | sed -r 's/(..)/0x\1 /g'))
ifconfig usb0 $USB0 netmask 255.255.255.0

### start iptables
$P/iptables.sh

### disable hdmi
tvservice -o

### power saving mode
iw dev wlan0 set power_save on

### join mesh
$P/badge_mesh_start.sh $ESSID

### power saving
echo none > /sys/class/leds/led0/trigger

### setup cowrie directories
mkdir -p /mnt/ram/cowrie/log /badge/data/ssh
rm -f /home/cowrie/cowrie/var/lib/cowrie/tty
ln -s /badge/data/ssh /home/cowrie/cowrie/var/lib/cowrie/tty
chown -R cowrie.cowrie /mnt/ram/cowrie /badge/data/ssh

### setup honeydb directories
mkdir -p /badge/data/honeydb
rm -rf /var/log/honeydb
ln -sf /badge/data/honeydb /var/log/honeydb
chown honeydb.honeydb -R /badge/data/honeydb

### setup unlock dirs
mkdir -p /badge/data/unlocks

# create create honeywap scoring log if it doesnt exist
if [ ! -f $LOG_HONEYWAP ]; then
  touch $LOG_HONEYWAP
fi

# create honeyssh scoring log if it doesnt exist
if [ ! -f $LOG_HONEYSSH ]; then
  touch $LOG_HONEYSSH
fi

# create honeydb scoring log if it doesnt exist
if [ ! -f $LOG_HONEYDB ]; then
  touch $LOG_HONEYDB
fi

# start ssh
systemctl start ssh.service

# start avahi-daemon
systemctl start avahi-daemon

# need restart to fix why power button handling doesn't work after a reboot
systemctl restart badge_button_handler_main_menu

### new root password every reboot
PW=$(/usr/bin/openssl rand -base64 12 | sed 's/.$//')
echo $PW > /root/passwd.txt
echo $PW >> /root/passwd.txt
cat /root/passwd.txt | passwd root
chmod 400 /root/passwd.txt

# disable RPI LED indicator to save 5ish mAh
echo 1 > /sys/class/leds/led0/brightness

### set honeypot DHCP scope from mac address
scope=$($P/mac2dhcp.sh | sed 's/\.0$//')
    #"data": "192.168.0.1"
#perl -p -i -e "s/\"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\"/\"$scope.1\"/g" $KEA_CONF_PATH/$KEA_HONEYPOT_CONF
  #{    "subnet": "192.168.0.0/24",
#perl -p -i -e "s/\"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}\"/\"$scope.0\/24\"/g" $KEA_CONF_PATH/$KEA_HONEYPOT_CONF
       #"pools": [ { "pool": "192.168.0.2 - 192.168.0.200" } ] }
#rand=$((65 + RANDOM % 140))
#perl -p -i -e "s/\"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+\-\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\"/\"$scope.$rand - $scope.253\"/g" $KEA_CONF_PATH/$KEA_HONEYPOT_CONF

$P/fix_honeydhcp.sh

### set honeypot nameserver from mac address
#server=/localnet/192.168.0.1
#address=/#/192.168.0.1
perl -p -i -e "s/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/$scope.1/g" /etc/dnsmasq.conf
