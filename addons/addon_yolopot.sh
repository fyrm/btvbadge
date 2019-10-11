#!/bin/bash

# keep this here to read badge variables
source /badge/bin/badge_vars.sh

INPUT=/tmp/menu.sh.$$

V=1

addon_help="This addon will join the badge to an open WiFi network and enable honeypot mode.  Use at your own risk.  Risks to badge include device explosion, fire or irreversable damage.  V$V"

dialog --begin 6 0 --no-lines --no-collapse --infobox "$addon_help" 13 40 \
  --and-widget --begin 0 5 --no-collapse --title "FiND OPEN WiFI" --no-tags --defaultno --yes-button "yes" --no-button "NO"  --yesno "Scan open WiFi?" 5 25

ret=$?
case "$ret" in
  0) ;; # yes
  1) clear;exit ;; # no
  *) exit ;;
esac

function honeypot_select_network {
  let i=0
  W=()
  while read -r line; do
    let i=$i+1
    W+=($line "$line")
		echo "found network $line"
  done < <( iwlist wlan0 scan | grep -Pzo "(?).*Encryption key:off\n.*ESSID:\".*\"" | strings | grep ESSID | grep -v 'ESSID:""' | sed 's/.*ESSID:\"//g; s/\"$//g' ) 

  let tot=$i+6

  if [ "$tot" -gt "15" ]; then tot=15; fi

  dialog --begin 0 0 --title "OPEN WiFi" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --menu "" $tot 17 $i "${W[@]}" 2>"${INPUT}"

  ret=$?

  case "$ret" in
    0) ;;
    1) exit ;;
    *) exit ;;
  esac

  menuitem=$(<"${INPUT}")

  if [ $? -eq 0 ]; then
    clear
    tput civis
		OSSID=$menuitem
    echo "joining network $OSSID"
    sleep 1
    clear
  fi
}

function honeypot_yolo_start {
	echo "resetting wlan0"
	ip addr flush dev wlan0
	ip link set wlan0 down
	ip link set wlan0 up

	honeypot_select_network

	echo "connecting to $OSSID"
	iw dev wlan0 connect $OSSID
	echo "sleeping 5s"
	sleep 5
	dhclient -i wlan0
	ip address show dev wlan0 | grep inet | awk '{print $2}'

	d=0
	c=0
  while [[ ! $oip =~ [0-9] ]]; do
    echo -n "."
    sleep 1
    ((c++))
    if [ "$c" -eq "5" ]; then
      c=0
      ((d++))
    fi
    if [ "$d" -eq "5" ]; then
      echo -n "timeout reached, could not obtain IP address."
			echo "this is a last second untested addon, you might need to PWR off/on badge to reset back to normal"
			exit
    fi
    oip=$(ip address show dev wlan0 | grep inet | awk '{print $2}')
  done

	echo "success!  IP address is $oip"
	echo "this is a last second untested addon, you might need to PWR off/on badge to reset back to normal when done"
	
}

function honeypot_partial_stop {
  echo "stopping honey AP"
	# honeypot_ap_stop
	kill $(ps auwx | grep hostapd-honeypot | grep -v grep | awk '{print $2}') >/dev/null 2>&1

  echo "stopping honeypot DNS"
  #honeypot_dns_stop
	eval systemctl stop dnsmasq $SUPPRESS

  echo "stopping honeypot DHCP server"
  #honeypot_dhcp_stop
  keapid=$(pgrep -f "/usr/sbin/kea-dhcp4 -c $KEA_CONF_PATH/$KEA_HONEYPOT_CONF")
  eval kill $keapid $SUPPRESS
  pkill -9 -x -f "/bin/bash /badge/bin/badge_honeydhcp.sh"
}

honeypot_partial_stop

honeypot_yolo_start
