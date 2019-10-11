#!/bin/bash
#
# DEF CON 27 Blue Team Village Badge
# Jeff Yestrumskas, FYRM Associates
#
# Latest updates at:
# https://fyrmassociates.com/BTVbadge
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

source /badge/bin/badge_vars.sh

INPUT=/tmp/menu.sh.$$

HANDLE=$(cat $DATA_HANDLE)
HONEYSSID=$(cat $DATA_HONEYSSID)
BLING_REPEAT=$(cat $DATA_BLING_REPEAT)
HONEYIP=$($P/mac2dhcp.sh | sed 's/\.0$/\.1/')

setfont $FONT_DEFAULT

# trap and delete temp files
trap "rm $INPUT; exit" SIGHUP SIGINT SIGTERM

tput civis

# SYSTEM STATS
function show_stats {
	$P/stats-dia.sh > $RD/stats-dia.txt
	dialog --clear --begin 0 0 --no-collapse --exit-label "ok" --title "SYSTEM iNFO" --textbox $RD/stats-dia.txt $MAXRES
}

function menu_about {
	while true; do
		let i=0
		W=()
		while read -r line; do
	    let i=$i+1
	    W+=($line "$line")
		done < <( find /badge/help -maxdepth 1 -name "*.fold" -type f | sort | sed 's/\/badge\/help\///g' | sed 's/\.txt\.fold//g' )

		let tot=$i+6
	
		if [ "$tot" -gt "15" ]; then tot=15; fi

		dialog --begin 0 18 --no-collapse  --no-lines --infobox "`cat /badge/art/question.txt`" 17 21 --and-widget \
		--begin 0 0 --no-collapse --title "[ HELP ]" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --menu "" $tot 8 $i "${W[@]}" 2>"${INPUT}"
 		ret=$?

	  case "$ret" in
 	   0) ;;
 	   1) break ;;
 	   *) exit ;;
	  esac

	  menuitem=$(<"${INPUT}")

		if [ $? -eq 0 ]; then
 	 		clear
			dialog --begin 0 0 --title "HELP: $menuitem" --exit-label "$LABELEXIT" --textbox /badge/help/$menuitem.txt.fold $MAXRES
		fi
	done
}

# SCORECARD
function show_scorecard {
	score_ssh=0
	score_wap=0
	score_honeydb=0
	score_friends=0

	if [ -f $LOG_HONEYSSH_SIMPLE ]; then	
		score_ssh=$(cat $LOG_HONEYSSH_SIMPLE | sort -u | wc -l)
	fi
	
	if [ -f $LOG_HONEYWAP_SIMPLE ]; then	
		score_wap=$(cat $LOG_HONEYWAP_SIMPLE | sort -u | wc -l)
	fi

	if [ -f $LOG_HONEYDB_SIMPLE ]; then	
		score_honeydb=$(cat $LOG_HONEYDB_SIMPLE | sort -u | wc -l)
	fi

	if [ -f $DATA_FRIENDS ]; then	
		score_friends=$(cat $DATA_FRIENDS | sort -u | wc -l)
	fi

	
	if [ $score_ssh -lt 10 ]; then score_ssh="0$score_ssh"; fi
	if [ $score_wap -lt 10 ]; then score_wap="0$score_wap"; fi
	if [ $score_honeydb -lt 10 ]; then score_honeydb="0$score_honeydb"; fi
	if [ $score_friends -lt 10 ]; then score_friends="0$score_friends"; fi

	clear

	tput bold
	tput setaf 6
	echo "          SSiD: $HONEYSSID"
	echo "        HANDLE: $HANDLE"
	echo "     AP POiNTS: $score_wap"
	echo "    SSH POiNTS: $score_ssh"
	echo " FRiEND POiNTS: $score_friends"
	echo "HONEYDB POiNTS: $score_honeydb"
	echo ""
	figlet -t -c -f future "$score_wap.$score_ssh.$score_friends.$score_honeydb"
	pause
	tput setaf 0
}

function show_hackme {
	clear
	tput bold
	tput setaf 6
	echo "                 SSiD:"
	figlet -t -c -f slant "$HONEYSSID"
	pause
	tput setaf 0
	clear
}

# SHOW AP LOG
function show_honeydhcplog {
	OUTPUT=$(cat $KEA_HONEYPOT_CSV)
	dialog --clear --begin 0 0 --no-collapse --title "HONEY DHCP" --msgbox "$OUTPUT" $MAXRES
}

function show_me {
	HANDLE=$(cat $DATA_HANDLE)
	HONEYSSID=$(cat $DATA_HONEYSSID)
	echo "    HANDLE: $HANDLE" > $RD/me.txt
	echo "HONEY SSiD: $HONEYSSID" >> $RD/me.txt
	echo ""
	echo -n "  UNLOCKED: " >> $RD/me.txt
	ls -C /badge/data/unlocks/ | sed 's/\.sh//g' | sed 's/  \+/ /g' >> $RD/me.txt	

  dialog --clear --begin 0 0 --no-collapse --exit-label "ok" --title "USER iNFO" --textbox $RD/me.txt $MAXRES
}

# SHOW INBOUND CONNETIONS
function show_inbound {
	netstat -an | grep ESTABLISHED | awk '{printf("%17s -> %-18s\n", $5, $4);}' | sed 's/:[0-9]* / /' > $RD/inbound-conns.txt
  dialog --clear --begin 0 0 --no-collapse --exit-label "ok" --title "iNBOUND CONNECTiONS" --textbox $RD/inbound-conns.txt $MAXRES
}

# LIST MESH NEIGHBORS
function mesh_neighbors {
	$P/badge_mesh_list.sh | column -c 40 -x -s " " -t | sort > $RD/bml.txt
	if [ -s $RD/bml.txt ]; then
		dialog --clear --begin 0 0 --no-collapse --exit-label "$LABELEXIT" --title "NEiGHBORS: $ESSID" --textbox $RD/bml.txt $MAXRES
	else
		dialog --clear --begin 0 6 --no-collapse --exit-label "$LABELEXIT" --title "NEiGHBORS: $ESSID" --msgbox "no badgenet neighbors" 6 26 
	fi
}

# TOGGLE SSH
function toggle_ssh {
	ssh_status=$(netstat -plant | grep sshd | awk '{print $7,"is listening on " $4}' | sed 's/^[0-9]*\///')
	if [ "$ssh_status" == "" ]
	then
		service ssh start $SUPPRESS
		sleep 3
		dialog --clear --begin 0 0 --no-collapse --title "SSH" --msgbox "`netstat -plant | grep sshd | awk '{print $7,\"is listening on \" $4}' | sed 's/^[0-9]*\///'`" 6 30
	else
		service ssh stop $SUPPRESS
		dialog --clear --begin 0 0 --no-collapse --title "SSH" --msgbox "SSH server is now inactive" 0 0
	fi
}

# SHOW MOTD
function show_motd {
	dialog --begin 0 0 --no-collapse --msgbox "`cat /etc/motd`" 0 0
}

# WHAT IS THE MATRIX?
function do_matrix {
	status_ticker_stop
	cmatrix -C cyan -s -a
	tput civis
	status_ticker_start
}

function do_images {
	while true; do
	let i=0
	W=()
	while read -r line; do
    let i=$i+1
    W+=($line "$line")
	done < <( find /badge/art/*.565 -maxdepth 1 -type f | sort | sed 's/\/badge\/art\///g' | sed 's/\.565//g')

	let tot=$i+6
	if [ "$tot" -gt "15" ]; then tot=15; fi

	dialog --begin 0 0 --title "iMAGES" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --menu "" $tot 20 $i "${W[@]}" 2>"${INPUT}"

  ret=$?

  case "$ret" in
    0) ;;
    1) break ;;
    *) exit ;;
  esac

  menuitem=$(<"${INPUT}")

	if [ $? -eq 0 ]; then
  	clear
		tput civis
		tail --bytes 153600 /badge/art/$menuitem.565 > /dev/fb1
  	read -rsn1
	fi
	done
}

### HONEYPOT ###
function menu_honeypot {
	while true; do
 	 dialog --begin 0 18 --no-collapse --cr-wrap --no-lines --infobox "`cat /badge/art/honeypot.txt;echo'';echo 'red bg color indicates honeypot is enabled'`" 17 21 --and-widget --begin 0 0 --no-collapse --title "[ HONEYPOT ]" \
 	 --no-tags --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --menu "" 15 9 15 \
		honeypot_status "status" \
		honeypot_all_start "enable" \
		honeypot_all_stop "disable" \
		honeypot_randomize "randomize" \
		show_scorecard "your score" \
		show_hackme "advertise" \
		honeypot_last_session "see last SSH" \
		honeypot_all_sessions "see all SSHs" \
		show_honeylogs "view logs" \
		honeypot_help "honey help" 2>"${INPUT}"
	
		# bug here, if using break instead of exit, sometimes it chooses honeypot_ap_toggle
		if [ $? == "1" ]; then break; fi
		menuitem=$(<"${INPUT}")

		case $menuitem in
			honeypot_status) honeypot_status;;
			show_scorecard) show_scorecard;;
			show_hackme) show_hackme;;
			honeypot_all_start) honeypot_all_start;;
			honeypot_all_stop) honeypot_all_stop;;
			honeypot_help) honeypot_help;;
			honeypot_randomize) honeypot_randomize;;
			show_honeylogs) show_honeylogs;;
			honeypot_all_sessions) honeypot_all_sessions;;
			honeypot_last_session) honeypot_last_session;;
			exit) break;;
		esac
	done
}

function honeypot_randomize {

  while true; do
		cur_services="current honeydb services (TCP):"
		cur_services+="\n\n"
		cur_services+=$(cat /etc/honeydb/services.conf | egrep "(low_port.*=|enabled.*|\[)" | xargs |sed 's/\[/\r\n/g; s/\]/ /g; s/tcp:/ /g;' | grep "enabled = Yes" | awk '{print $1"("$4")"}' | tr '\r\n' ' ')
		cur_services+="\n\n"

		dialog --begin 6 0 --no-lines --no-collapse --infobox "$cur_services" 10 40 \
		--and-widget --begin 0 5 --no-collapse --title "RANDOMiZE SERViCES" --no-tags --defaultno --yes-button "yes" --no-button "KEEP"  --yesno "randomize honeydb services?  restart honeypot to take effect" 0 0 
	
		ret=$?
		case "$ret" in
			0) eval $P/badge_honeydb_rand.sh;;
			1) break ;; # "no"
			*) break ;;
		esac
	done
}

function honeypot_help {
	dialog --clear --begin 0 0 --no-collapse --exit-label "$LABELEXIT" --title "HONEYPOT HELP" --textbox /badge/help/honeypot.txt.fold $MAXRES
}

function show_honeylogs {
	if [ -z "$(ls -A $LOG_ALL_SIMPLE)" ]; then
  	dialog --clear --begin 0 0 --no-collapse --title "HONEY LOGS" --msgbox "there are no honeypot logs.  perhaps try setting a more enticing SSID and enabling the honeypot" 8 40
	else
		tac $LOG_ALL_SIMPLE > $RD/las.txt	
		dialog --clear --begin 0 0 --no-collapse --exit-label "$LABELEXIT" --title "HONEY LOGS (new 1st)" --textbox "$RD/las.txt" $MAXRES
	fi
}

function honeypot_all_start {
	if [[ $HANDLE =~ ^NPC.* ]] || [[ $HONEYSSID =~ ^NPC.* ]]; then
		dialog --begin 0 4 --ok-label "$LABELOK" --msgbox "your handle and honeypot SSID must not begin with NPC.  please configure in setup." 0 0
		return
	fi

	status_ticker_main_stop
	clear 
	tput bold
	echo "leaving badgenet $ESSID"
	mesh_stop
	echo "starting honeypot wireless interface"
	honeypot_wlan0_start
	echo "starting honeypot firewall"
	honeypot_iptables_start
	echo -n "starting SSH honeypot"
	honeypot_ssh_start
	echo "starting honeydb.io agent"
	honeypot_honeydb_start
	echo "starting honeypot access point"
	honeypot_ap_start
	echo "starting honeypot DNS server"
	honeypot_dns_start
	# fix why IP isn't always set
	honeypot_wlan0_start
	echo "starting honeypot DHCP server"
	honeypot_dhcp_start
	echo "honeypot mode enabled"
	ln -sf $DRCRED $DRC
	status_ticker_stop
	status_ticker_honey_start
}

function honeypot_all_stop {
	ln -sf $DRCCYAN $DRC
	status_ticker_stop
	clear
	tput bold
	echo "stopping SSH honeypot"
	honeypot_ssh_stop
	echo "stopping honeydb.io agent"
	honeypot_honeydb_stop
	echo "stopping honeypot access point"
	honeypot_ap_stop
	echo "stopping honeypot DNS server"
	honeypot_dns_stop
	echo "stopping honeypot DHCP server"
	honeypot_dhcp_stop
	echo "stopping honeypot firewall"
	honeypot_iptables_stop
	echo "stopping honeypot wireless interface"
	honeypot_wlan0_stop
	echo "honeypot mode disabled"
	echo "joining badge network $ESSID"
	mesh_start
	status_ticker_honey_stop
	status_ticker_start
}

function honeypot_iptables_start {
	$IPTABLES_HONEYPOT
}

function honeypot_iptables_stop {
	iptables -F
	iptables -t nat -F
	iptables -t mangle -F
}

function honeypot_wlan0_start {
	ip addr flush dev wlan0
	ip link set wlan0 down
	eval ip addr add $HONEYIP/24 dev wlan0
	ip link set wlan0 up
	sleep 1
}

function honeypot_wlan0_stop {
	ip addr flush dev wlan0
	ip link set wlan0 down
	sleep 1
}

function honeypot_dhcp_start {
  eval /usr/sbin/kea-dhcp4 -c $KEA_CONF_PATH/$KEA_HONEYPOT_CONF $SUPPRESS &
	sleep 1
  eval $P/badge_honeydhcp.sh & 
}

function honeypot_dhcp_stop {
	keapid=$(pgrep -f "/usr/sbin/kea-dhcp4 -c $KEA_CONF_PATH/$KEA_HONEYPOT_CONF")
	eval kill $keapid $SUPPRESS	
  pkill -9 -x -f "/bin/bash /badge/bin/badge_honeydhcp.sh"
}

function honeypot_dns_start {
	eval systemctl start dnsmasq $SUPPRESS
	sleep 1
}

function honeypot_dns_stop {
	eval systemctl stop dnsmasq $SUPPRESS
	sleep 1
}

function honeypot_status {
	cur_honeyap_status=$(pgrep -f "/usr/sbin/hostapd -d $HOSTAPD_CONF_PATH/$HOSTAPD_HONEYPOT_CONF")
	cur_cowrie_status=$(pgrep -f "/home/cowrie/cowrie/cowrie-env/bin/python2 /home/cowrie/cowrie/cowrie-env/bin/twistd")
	cur_honeyhttpd_status=$(pgrep -f "^python2 start.py --config config.json")
	cur_honeydb_status=$(pgrep -f -x "/usr/sbin/honeydb-agent")
	tmpns_honeydb_services=$(netstat -plat | grep honeydb-agent | sed 's/:/ /g' | awk '{print $5}' | sort -n | xargs)
	cur_honeydb_services=""
  while read -r line; do
		arr=(${line})
		for i in $tmpns_honeydb_services; do
			if [ $i == ${arr[1]} ]; then
				cur_honeydb_services+="${arr[0]} "
			fi
		done
  done < <(cat /etc/honeydb/services.conf | egrep "(port.*=|enabled.*|\[)" | xargs |sed 's/\[/\r\n/g; s/\]/ /g; s/tcp:/ /g;' | grep "enabled = Yes" | awk '{print $1, $7}')
		
	cur_kea_status=$(pgrep -f "/usr/sbin/kea-dhcp4 -c $KEA_CONF_PATH/$KEA_HONEYPOT_CONF")
	cur_dnsmasq_status=$(pgrep -f "/usr/sbin/dnsmasq -x /run/dnsmasq/dnsmasq.pid")
	cur_wlan0_status=$(ifconfig wlan0 | grep inet | awk '{print $2}')

	if [[ $cur_cowrie_status =~ [0-9] ]]
		then
			hs="HONEY SSH : UP"
		else
			hs="HONEY SSH : DOWN"
	fi

	if [[ $cur_dnsmasq_status =~ [0-9] ]]
		then
			hs="$hs\nHONEY DNS : UP"
		else
			hs="$hs\nHONEY DNS : DOWN"
	fi

	if [[ $cur_kea_status =~ [0-9] ]]
		then
			hs="$hs\nHONEY DHCP: UP"
		else
			hs="$hs\nHONEY DHCP: DOWN"
	fi

 	if [[ $cur_honeyap_status =~ [0-9] ]]
		then
			hs="$hs\nHONEY WAP : UP"
			out="   SSID: `cat $HOSTAPD_CONF_PATH/$HOSTAPD_HONEYPOT_CONF | grep ^ssid | sed 's/ssid=//g'`\n"
		else
			hs="$hs  \nHONEY WAP : DOWN"
	fi

	if [[ $cur_honeydb_status =~ [0-9] ]]
		then
			hs="$hs\nHONEYDB.IO: UP"
			if [[ $cur_honeydb_services =~ [a-z] ]]; then
				out+="HONEYDB: $cur_honeydb_services"
			else
				out="honeydb.io services still loading, revisit status shortly"
			fi
		else
			hs="$hs\nHONEYDB.IO: DOWN"
			out=""
	fi



dialog --begin 8 0 --no-lines --no-collapse --infobox "$out" 9 40 --and-widget --begin 0 10 --ok-label "$OKLABEL" --title "HONEYPOT STATUS" --msgbox "$hs" 9 20 
}

function honeypot_ap_start {
	pkill -f -x "/bin/bash /badge/bin/badge_honeyap.sh"
	setsid $P/badge_honeyap.sh &
	disown
}

function honeypot_ap_stop {
	kill $(ps auwx | grep hostapd-honeypot | grep -v grep | awk '{print $2}') >/dev/null 2>&1
	#rm -f $LOG_HONEYWAP_SIMPLE
}

function honeypot_www_start {
	su honeyhttpd -c "cd /home/honeyhttpd/honeyhttpd;python2 start.py --config config.json $SUPPRESS &"
}

function honeypot_honeydb_start {
	pkill -f -x "/bin/bash /badge/bin/badge_honeydb.sh"
	setsid $P/badge_honeydb.sh &
	disown
}

function honeypot_honeydb_stop {
	pkill -f -x "/bin/bash /badge/bin/badge_honeydb.sh"
	pkill -f "xtail -F"
	systemctl stop honeydb-agent
}

function honeypot_www_stop {
	pkill -9 -x -f "python2 start.py --config config.json"
	rm -f $HONEYWWWLOG/*.log
}	

function honeypot_ssh_start {
	su cowrie -c "/home/cowrie/cowrie/bin/cowrie restart $SUPPRESS &" 

	c=0
	while [ ! -f $COWRIELOG ]; do
		echo -n "."
		sleep 1
		let c=$c+1
		if [ "$c" -eq "45" ]; then
			echo "timeout reached"
			break
		fi
	done
	echo ""
	cowrie_status=$(ps axuww | grep cowrie.pid | grep -v grep | awk '{print $2}')
	pkill -f -x "/bin/bash /badge/bin/badge_honeyssh.sh"
	eval $P/badge_honeyssh.sh &
}

function honeypot_ssh_stop {	
	su cowrie -c "/home/cowrie/cowrie/bin/cowrie stop > /dev/null"
	pkill -9 -x -f "/bin/bash /badge/bin/badge_honeyssh.sh"
	rm -f $COWRIELOG
	#rm -f $LOG_HONEYSSH_SIMPLE
}

function honeypot_play_session {
	session=$1
	status_ticker_stop
	atime=$(stat $COWRIELOGS/$session | grep Modify: | awk '{print $2 "-" $3}' | sed 's/\..*//')
	clear
	printf "${CYAN}replaying session $atime\n${NC}"
	sleep 2
	tput cvvis
	su cowrie -c "/home/cowrie/cowrie/bin/playlog -c $COWRIELOGS/$session"
	tput civis
	printf "${NC}${CYAN}\n\nend of session $atime"
	pause
	status_ticker_start
}

function honeypot_last_session {
	if [ -z "$(ls -A $COWRIELOGS)" ]; then
  	dialog --clear --begin 0 0 --no-collapse --title "SSH REPLAY" --msgbox "there are no SSH honeypot sessions to replay.  perhaps try setting a more enticing SSID and enabling the honeypot" 8 40
		return 1
	fi

	LATEST=`ls -tp $COWRIELOGS | grep -v /$ | head -1`
	honeypot_play_session "$LATEST"
}

function honeypot_all_sessions {

	if [ -z "$(ls -A $COWRIELOGS)" ]; then
  	dialog --clear --begin 0 0 --no-collapse --title "SSH REPLAY" --msgbox "there are no SSH honeypot sessions to replay.  perhaps try setting a more enticing SSID and enabling the honeypot" 8 40
		return 1
	fi

	while true; do
		let i=0
		W=()
		while read -r line; do
	    let i=$i+1
			atime=$(stat $COWRIELOGS/$line | grep Modify: | awk '{print $2 "-" $3}' | sed 's/\..*//')
	    W+=($line "$atime")
		done < <( find $COWRIELOGS -maxdepth 1 -type f | sort | sed 's/\// /g' | awk '{print $4}' )

		let tot=$i+6
		if [ "$tot" -gt "15" ]; then tot=15; fi

		dialog --title "HONEY SSH SESSiONS" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --menu "" $tot 25 $i "${W[@]}" 2>"${INPUT}"

 		ret=$?

	  case "$ret" in
 	   0) ;;
 	   1) break ;;
 	   *) exit ;;
	  esac

	  menuitem=$(<"${INPUT}")

		if [ $? -eq 0 ]; then
			honeypot_play_session "$menuitem"
		fi
	done

}

### END HONEYPOT ###

function iptables_start {
	$IPTABLES
}

function iptables_stop {
	iptables -F
	iptables -t nat -F
	iptables -t mangle -F
}

function show_debug {
	dialog --begin 0 0 --clear --title "debug" --msgbox "screensize" 0 0
}

function start_led_wigwag {
	stop_led_all
	setsid $P/bling_led_shiftreg.py wigwag $BLING_REPEAT .05 &
}

function start_led_split {
	stop_led_all
	setsid $P/bling_led_shiftreg.py split $BLING_REPEAT .09 &
}

function start_led_flash {
	stop_led_all
	setsid $P/bling_led_shiftreg.py flash $BLING_REPEAT .05 &
}

function start_led_matrix {
	stop_led_all
	setsid $P/bling_led_shiftreg.py matrix $BLING_REPEAT .07 &
}

function stop_led_all {
	#ledpid=$(pgrep -f "python /badge/bin/bling_led_shiftreg.py .*")
  #eval kill $ledpid $SUPPRESS
	#eval $P/bling_led_shiftreg.py cleanup $SUPPRESS &
	eval $P/bling_stop_led.sh
}

function sao_soft_toggle {
	sat=$($P/sao_soft_toggle.py toggle)
	dialog --clear --begin 0 13 --no-collapse --title "SAO" --msgbox "$sat" 0 0
}

function menu_bling {
	while true; do
	ib=$(cat /badge/art/bling.txt)

	line=$(ps axuww | grep -v grep | egrep "python /badge/bin/bling_led_shiftreg.py")

	if [[ $line =~ .*/bling_led_shiftreg.py[[:space:]]([a-z]+)[[:space:]](.?[0-9]+)[[:space:]](.?[0-9]+) ]]; then
		bstyle=${BASH_REMATCH[1]}
		bdelay=${BASH_REMATCH[2]}
		BLING_INLOOP=${BASH_REMATCH[3]}
		ib+=$(printf "\n\nLED bling: ON")
		ib+=$(printf "\nLED style: $bstyle")
		ib+=$(printf "\nLED cycle: ${bdelay}s")
		ib+=$(printf "\nloop time: ${BLING_INLOOP}s")
	else
		ib+=$(printf "\n\nLED bling: OFF")
	fi

	dialog --begin 0 18 --no-lines --no-collapse --infobox "$ib" 17 21 --and-widget --begin 0 0 --no-collapse --title "[ BLiNG ]" \
	--no-tags --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --menu "" 15 10 9 \
	do_matrix "matrix" \
	do_images "images" \
	do_ansi "ANSi art" \
	start_led_wigwag "LED wigwag" \
	start_led_split "LED split" \
	start_led_flash "LED flash" \
	start_led_matrix "LED matrix" \
	stop_led_all "LEDs off" \
	menu_bling_repeat "delay sec" 2>"${INPUT}"
	
	ret=$?
	case "$ret" in
		0) ;;
		1) break ;;
		*) exit ;;
	esac

	menuitem=$(<"${INPUT}")

	case $menuitem in
		do_matrix) do_matrix;;
		do_images) do_images;;
		do_ansi) do_ansi;;
		sao_soft_toggle) sao_soft_toggle;;
		start_led_wigwag) start_led_wigwag;;
		start_led_split) start_led_split;;
		start_led_flash) start_led_flash;;
		start_led_matrix) start_led_matrix;;
		stop_led_all) stop_led_all;;
		menu_bling_repeat) menu_bling_repeat;;
		exit) break;;
	esac
	done
}

function do_ansi {
	if [ -t 0 ]; then stty -echo -icanon -icrnl time 0 min 0; fi

	status_ticker_stop
	clear
	$P/ansi.pl &
	count=0
	keypress=''
	while [ "x$keypress" = "x" ]; do
		let count+=1
		keypress="`cat -v`"
		sleep 1;
	done

	pkill -x -f "/usr/bin/perl /badge/bin/ansi.pl"

	if [ -t 0 ]; then stty sane; fi
	status_ticker_start
	clear
}

function menu_bling_repeat {
	while true; do
	dialog --begin 0 25 --no-lines --no-collapse --infobox "`cat /badge/art/led.txt`" 17 21 --and-widget --begin 0 0 --no-collapse --title "[ BLiNG REPEAT ]" \
		--no-tags --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --menu "" 11 8 5 \
	3 "3s" \
	10 "10s" \
	30 "30s" \
	60 "60s" \
	31337 "31337s" 2>"${INPUT}"

	ret=$?
	case "$ret" in
		0) ;;
		1) break ;;
		*) exit ;;
	esac
	
	menuitem=$(<"${INPUT}")

	case $menuitem in
		3) BLING_REPEAT=3;reset_bling;break;;
		10) BLING_REPEAT=10;reset_bling;break;;
		30) BLING_REPEAT=30;reset_bling;break;;
		60) BLING_REPEAT=60;reset_bling;break;;
		31337) BLING_REPEAT=31337;reset_bling;break;;
		exit) break;;
	esac
	done
}

function reset_bling {
	echo $BLING_REPEAT > $DATA_BLING_REPEAT
	line=$(ps axuww | grep -v grep | egrep "python /badge/bin/bling_led_shiftreg.py")
  if [[ $line =~ .*/bling_led_shiftreg.py[[:space:]]([a-z]+)[[:space:]](.?[0-9]+)[[:space:]](.?[0-9]+) ]]; then
    bstyle=${BASH_REMATCH[1]}
    bdelay=${BASH_REMATCH[2]}
    BLING_INLOOP=${BASH_REMATCH[3]}
		stop_led_all
  	setsid $P/bling_led_shiftreg.py $bstyle $BLING_REPEAT $BLING_INLOOP &
	fi
}

function config_reset {
	dialog --begin 4 5 --no-collapse --title "RESET BADGE" --no-tags --defaultno --yes-button "yes" --no-button "NO"  --yesno "reset all configuration and scoring? if yes, badge will restart." 0 0
	
	ret=$?
	case "$ret" in
		0) eval $P/badge_erase.sh;;
		1) ;; # no
		*) exit ;;
	esac
}

### BEGIN CONFIG
function menu_setup {

	while true; do
	curssid=$(iwconfig wlan0 | grep ESSID | sed 's/[:"]/ /g' | awk '{print $5}')
	if [ "$curssid" == "$ESSID" ]; then
		togname="exit"
	else
		togname="join"
	fi

	dialog --begin 0 14 --no-lines --no-collapse --infobox "`cat /badge/art/dna.txt`" 17 21 --and-widget --begin 0 0 --no-collapse --title "[ SETUP ]" \
		--no-tags --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --menu "" 14 19 14 \
	config_name "handle" \
	config_honey_ssid "honey ssid" \
	show_stats "sys info" \
	show_inbound "list conns" \
	usb0_toggle "USB ethernet" \
	mesh_$togname "$togname badgenet" \
	power_off "power off" \
	config_reset "reset data" 2>"${INPUT}"

	ret=$?
	case "$ret" in
		0) ;;
		1) break ;;
		*) exit ;;
	esac
	
	menuitem=$(<"${INPUT}")

	case $menuitem in
		config_reset) config_reset;;
		power_off) $P/shutdown.sh;;
		usb0_toggle) usb0_toggle;;
		show_stats) show_stats;;
		show_inbound) show_inbound;;
		mesh_join) mesh_start;sleep 2;;
		mesh_exit) mesh_stop;sleep 2;;
		config_name)
			config_file_val $DATA_HANDLE 'HANDLE' /badge/art/dna.txt
			HANDLE=$(cat $DATA_HANDLE)
			hostname $HANDLE
			avahi-set-host-name $HANDLE	
		;;
		config_honey_ssid)
			config_file_val $DATA_HONEYSSID 'HONEY SSID' /badge/art/antenna.txt
			HONEYSSID=$(cat $DATA_HONEYSSID)
		;;
		exit) break;;
	esac
	done
}

# creates selectable A-Z field to save data to a text file
function config_file_val {
	status_ticker_stop
	# config_file_val /badge/data/honeyssid.txt 'HONEY SSID' /badge/art/dna.txt
	config_file="$1"
	config_tit="$2"
	config_art="$3"
	NAME=""
	TIT=$config_tit
	if [ -f $config_file ]; then
		TIT="$config_tit: `cat $config_file`"
	fi

	while true; do
	dialog --begin 0 18 --no-lines --no-collapse --infobox "`cat $config_art`" 17 21 --and-widget --begin 0 0 --no-collapse --title "[ $TIT ]" \
	--no-tags --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --extra-button --extra-label "save" --menu "$NAME" 25 11 25 \
	a "${NAME}a" \
	A "${NAME}A" \
	b "${NAME}b" \
	B "${NAME}B" \
	c "${NAME}c" \
	C "${NAME}C" \
	d "${NAME}d" \
	D "${NAME}D" \
	e "${NAME}e" \
	E "${NAME}E" \
	f "${NAME}f" \
	F "${NAME}F" \
	g "${NAME}g" \
	G "${NAME}G" \
	h "${NAME}h" \
	H "${NAME}H" \
	i "${NAME}i" \
	I "${NAME}I" \
	j "${NAME}j" \
	J "${NAME}J" \
	k "${NAME}k" \
	K "${NAME}K" \
	l "${NAME}l" \
	L "${NAME}L" \
	m "${NAME}m" \
	M "${NAME}M" \
	n "${NAME}n" \
	N "${NAME}N" \
	o "${NAME}o" \
	O "${NAME}O" \
	p "${NAME}p" \
	P "${NAME}P" \
	q "${NAME}q" \
	Q "${NAME}Q" \
	r "${NAME}r" \
	R "${NAME}R" \
	s "${NAME}s" \
	S "${NAME}S" \
	t "${NAME}t" \
	T "${NAME}T" \
	u "${NAME}u" \
	U "${NAME}U" \
	v "${NAME}v" \
	V "${NAME}V" \
	w "${NAME}w" \
	W "${NAME}W" \
	x "${NAME}x" \
	X "${NAME}X" \
	y "${NAME}y" \
	Y "${NAME}Y" \
	z "${NAME}z" \
	Z "${NAME}Z" \
	0 "${NAME}0" \
	1 "${NAME}1" \
	2 "${NAME}2" \
	3 "${NAME}3" \
	4 "${NAME}4" \
	5 "${NAME}5" \
	6 "${NAME}6" \
	7 "${NAME}7" \
	8 "${NAME}8" \
	9 "${NAME}9" 2>"${INPUT}"

	ret=$?

	case "$ret" in
		0) ;;
		1) break ;;
		3) 
			if [ "$config_tit" == "HANDLE" ];then
				HANDLE=$(echo $NAME | sed 's/ //g')
				hostname $HANDLE
				echo "$HANDLE" > /etc/hostname
				echo $HANDLE > $config_file
				sed -i -e "s/^host-name=.*/host-name=$HANDLE/" /etc/avahi/avahi-daemon.conf	
				systemctl restart avahi-daemon
			fi
			if [ "$config_tit" == "HONEY SSID" ];then
				HONEYSSID=$NAME
				sed -i -e "s/^ssid=.*/ssid=$HONEYSSID/" $HOSTAPD_CONF_PATH/$HOSTAPD_HONEYPOT_CONF
				echo $HONEYSSID > $config_file
			fi
			break ;;
		*) exit ;;
	esac

	menuitem=$(<"${INPUT}")

	case $menuitem in
		_) NAME+=" ";;
		A) NAME+=A;;
		B) NAME+=B;;
		C) NAME+=C;;
		D) NAME+=D;;
		E) NAME+=E;;
		F) NAME+=F;;
		G) NAME+=G;;
		H) NAME+=H;;
		I) NAME+=I;;
		J) NAME+=J;;
		K) NAME+=K;;
		L) NAME+=L;;
		M) NAME+=M;;
		N) NAME+=N;;
		O) NAME+=O;;
		P) NAME+=P;;
		Q) NAME+=Q;;
		R) NAME+=R;;
		S) NAME+=S;;
		T) NAME+=T;;
		U) NAME+=U;;
		V) NAME+=V;;
		W) NAME+=W;;
		X) NAME+=X;;
		Y) NAME+=Y;;
		Z) NAME+=Z;;
		a) NAME+=a;;
		b) NAME+=b;;
		c) NAME+=c;;
		d) NAME+=d;;
		e) NAME+=e;;
		f) NAME+=f;;
		g) NAME+=g;;
		h) NAME+=h;;
		i) NAME+=i;;
		j) NAME+=j;;
		k) NAME+=k;;
		l) NAME+=l;;
		m) NAME+=m;;
		n) NAME+=n;;
		o) NAME+=o;;
		p) NAME+=p;;
		q) NAME+=q;;
		r) NAME+=r;;
		s) NAME+=s;;
		t) NAME+=t;;
		u) NAME+=u;;
		v) NAME+=v;;
		w) NAME+=w;;
		x) NAME+=x;;
		y) NAME+=y;;
		z) NAME+=z;;
		0) NAME+=0;;
		1) NAME+=1;;
		2) NAME+=2;;
		3) NAME+=3;;
		4) NAME+=4;;
		5) NAME+=5;;
		6) NAME+=6;;
		7) NAME+=7;;
		8) NAME+=8;;
		9) NAME+=9;;
		exit) exit;break;;
	esac
	done
	status_ticker_start
}
### END CONFIG

function kea_dhcp_enable {
	USB0=$(printf '192.168.7.%d\n' $(echo `ifconfig wlan0 | grep ether | awk '{print $2}' | cut -d':' -f6 | sed 's/://g'` | sed -r 's/(..)/0x\1 /g'))

	kill `pgrep -f "/usr/sbin/kea-dhcp4 -c $KEA_CONF_PATH/$KEA_DHCP_CONF"`
	eval /usr/sbin/kea-dhcp4 -c $KEA_CONF_PATH/$KEA_DHCP_CONF $SUPPRESS &

	kea_status=0
	c=0
	d=0
	while [[ ! $kea_status =~ $USB0:67 ]]; do
		echo -n "."
		sleep 1
		((c++))
		if [ "$c" -eq "5" ]; then
			kill `pgrep -f "/usr/sbin/kea-dhcp4 -c $KEA_CONF_PATH/$KEA_DHCP_CONF"`
			eval /usr/sbin/kea-dhcp4 -c $KEA_CONF_PATH/$KEA_DHCP_CONF $SUPPRESS &
			c=0
			((d++))
		fi
		if [ "$d" -eq "5" ]; then
			echo -n "timeout reached"
			break
		fi
		kea_status=$(netstat -plan | grep $USB0:67 | awk '{print $4}')
	done
}

function kea_dhcp_disable {
	eval kill `pgrep -f "/usr/sbin/kea-dhcp4 -c $KEA_CONF_PATH/$KEA_DHCP_CONF"`
}

function hdmi_enable {
	tvservice -p
}

function hdmi_disable {
	tvservice -o
}

function usb0_enable {
	clear
	USB0=$(printf '192.168.7.%d\n' $(echo `ifconfig wlan0 | grep ether | awk '{print $2}' | cut -d':' -f6 | sed 's/://g'` | sed -r 's/(..)/0x\1 /g'))

	kea_dhcp_disable

	echo "loading kernel module"
	modprobe g_ether

	echo "configuring interface"
	ip addr flush dev usb0
	ip link set usb0 down
	eval ip addr add $USB0/24 dev usb0
	ip link set usb0 up

	echo -n "enabling DHCP server"
	kea_dhcp_enable
	pause

	usb0_toggle
}

function usb0_disable {
	clear
	echo "disabling DHCP server"
	kea_dhcp_disable

	echo "disabling usb0"
	ip addr flush dev usb0
	ip link set usb0 down

	echo "unloading kernel module"
	rmmod g_ether

	sleep 3

	ifconfig usb0 | head -1
	echo ""
	lsmod | grep g_ether
	pause
	usb0_toggle
}

function usb0_toggle {
	USB0=$(printf '192.168.7.%d\n' $(echo `ifconfig wlan0 | grep ether | awk '{print $2}' | cut -d':' -f6 | sed 's/://g'` | sed -r 's/(..)/0x\1 /g'))

	usb0_status=$(ip addr show usb0 |grep state | awk '{print $9}')
	kea_status=$(pgrep -x -f "/usr/sbin/kea-dhcp4 -c $KEA_CONF_PATH/$KEA_DHCP_CONF")
	keanet_status=$(netstat -plan | grep $USB0:67 | awk '{print $4}')
	usbether_status=$(lsmod | grep ^g_ether | awk '{print $1}')
	sshd_status=$(netstat -plan | egrep LISTEN.*sshd | awk '{print $4}' | sed 's/.*://')

	# if any of the following are not running, provide option to startup everything
	enstatus="disable"

	if [[ $usbether_status =~ g_ether ]]; then
		echo "KMOD: loaded" > $RD/usb.txt
	else
		echo "KMOD: not loaded" > $RD/usb.txt
		enstatus="enable"
	fi

	if [[ $keanet_status =~ $USB0:67 ]]; then
		echo "DHCP: UP" >> $RD/usb.txt
	else
		echo "DHCP: DOWN" >> $RD/usb.txt
		enstatus="enable"
	fi

	if [[ $usb0_status =~ UP ]]; then
		echo "USB0: $USB0" >> $RD/usb.txt
		echo "SSHD: tcp $sshd_status" >> $RD/usb.txt
		echo "root: $(head -1 /root/passwd.txt)" >> $RD/usb.txt
	else
		echo "USB0: DOWN" >> $RD/usb.txt
		enstatus="enable"
	fi

		enmsg="\nconnect USB data cable to middle port on RPI before enabling"

	dialog --begin 7 2 --no-lines --no-collapse --infobox "`cat /badge/art/pi.txt`" 9 40 \
		--and-widget --begin 0 17 --no-lines --no-collapse --infobox "`cat $RD/usb.txt`" 7 25 \
		--and-widget --begin 0 0 --no-collapse --title "[ USB ETHERNET ]" \
		--no-tags --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --menu "" 7 6 7 \
	usb0_do "$enstatus" 2>"${INPUT}" --and-widget \
	--begin 15 1 --no-collapse --infobox "asdf" 5 5

	ret=$?
	case "$ret" in
		0) ;;
		1) break ;;
		*) exit ;;
	esac
	
	menuitem=$(<"${INPUT}")

	case $menuitem in
		usb0_do) eval usb0_$enstatus;;
		exit) break;;
	esac

}


function mesh_start {
	eval $P/badge_mesh_start.sh $ESSID
}

function mesh_stop {
	eval $P/badge_mesh_stop.sh
}

function mesh_shutdown {
	clear
	echo "please wait, running tasks in parallel"

	if [ -f /badge/admin/flash_on_update.txt ]; then
		$PA/badge_mesh_exec_bg.sh "$PA/badge_update_flash.sh"
	fi

	$PA/badge_mesh_exec_bg.sh "$P/shutdown.sh"
}

function mesh_reboot {
	clear
	echo "please wait, running tasks in parallel" 

	if [ -f /badge/admin/flash_on_update.txt ]; then
		$PA/badge_mesh_exec_bg.sh "$PA/badge_update_flash.sh"
	fi

	$PA/badge_mesh_exec_bg.sh "$P/reboot.sh"
}

function mesh_deploy {
	clear
	echo "please wait, running tasks in parallel"
	
	if [ -f /badge/admin/flash_on_update.txt ]; then
		$PA/badge_mesh_exec_bg.sh "$PA/badge_update_flash.sh"
	fi

	/badge/deploy/deploy-all.sh | tee $RD/bmd.txt
	dialog --clear --begin 0 0 --no-collapse --exit-label "$LABELEXIT" --title "DEPLOY: $ESSID" --textbox $RD/bmd.txt $MAXRES
}

function mesh_deploy_addons {
	clear
	echo "please wait, running tasks in parallel"
	
	if [ -f /badge/admin/flash_on_update.txt ]; then
		$PA/badge_mesh_exec_bg.sh "$PA/badge_update_flash.sh"
	fi

  if [ -f /badge/admin/lite_addons.txt ]; then
		/badge/deploy/deploy-all-addons-lite.sh | tee $RD/bmd.txt
  else
		/badge/deploy/deploy-all-addons.sh | tee $RD/bmd.txt
	fi
	dialog --clear --begin 0 0 --no-collapse --exit-label "$LABELEXIT" --title "DEPLOY: $ESSID" --textbox $RD/bmd.txt $MAXRES
}

function mesh_deploy_one {
	clear
	echo "please wait, running tasks in parallel"
	eval $PA/badge_mesh_version_bg.sh | column -c 40 -x -s " " -t | sort | tee $RD/bmdo.txt
	while true; do
		let i=0
		W=()
		while read -r line; do
	    let i=$i+1
	    W+=("$line" "$line")
		done < <( cat $RD/bmdo.txt )

		let tot=$i+6
		if [ "$tot" -gt "15" ]; then tot=15; fi

		dialog --title "AVAiL NODES" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --menu "" 0 0 $i "${W[@]}" 2>"${INPUT}"

 		ret=$?

	  case "$ret" in
 	   0) ;;
 	   1) break ;;
 	   *) exit ;;
	  esac

	  menuitem=$(<"${INPUT}")

		if [ $? -eq 0 ]; then
 	 		clear
			# not ideal, but it works for now
			
			target=($menuitem)
			echo "deploying to ${target[0]}"
			/badge/deploy/deploy.sh ${target[0]}
			pause
			break
		fi
	done
}

function mesh_deploy_one_addons {
	clear
	echo "please wait, running tasks in parallel"
	#eval $PA/badge_mesh_version_bg.sh | column -c 40 -x -s " " -t | sort | tee $RD/bmdo.txt
	eval $P/badge_mesh_list.sh | column -c 40 -x -s " " -t | sort | tee $RD/bmdo.txt
	while true; do
		let i=0
		W=()
		while read -r line; do
	    let i=$i+1
	    W+=("$line" "$line")
		done < <( cat $RD/bmdo.txt )

		let tot=$i+6
		if [ "$tot" -gt "15" ]; then tot=15; fi

		dialog --title "AVAiL NODES" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --menu "" 0 0 $i "${W[@]}" 2>"${INPUT}"

 		ret=$?

	  case "$ret" in
 	   0) ;;
 	   1) break ;;
 	   *) exit ;;
	  esac

	  menuitem=$(<"${INPUT}")

		if [ $? -eq 0 ]; then
 	 		clear
			# not ideal, but it works for now
			
			target=($menuitem)
			echo "deploying to ${target[0]}"
  		if [ -f /badge/admin/lite_addons.txt ]; then
				/badge/deploy/deploy-addons-lite.sh ${target[0]}
  		else
				/badge/deploy/deploy-addons.sh ${target[0]}
			fi
			pause
			break
		fi
	done
}
function mesh_honeydb_pull_one {
	clear
	echo "please wait, running tasks in parallel"
	eval $PA/badge_mesh_version_bg.sh | column -c 40 -x -s " " -t | sort | tee $RD/hnpo.txt
	while true; do
		let i=0
		W=()
		while read -r line; do
	    let i=$i+1
	    W+=("$line" "$line")
		done < <( cat $RD/hnpo.txt )

		let tot=$i+6
		if [ "$tot" -gt "15" ]; then tot=15; fi

		if [ $i -eq 0 ]; then
			echo "no nodes available"
			pause
			break
		fi

		dialog --title "AVAiL NODES HONEYDB PULL" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --menu "" 0 0 $i "${W[@]}" 2>"${INPUT}"

 		ret=$?

	  case "$ret" in
 	   0) ;;
 	   1) break ;;
 	   *) break ;;
	  esac

	  menuitem=$(<"${INPUT}")

		if [ $? -eq 0 ]; then
 	 		clear
			# not ideal, but it works for now
			
			target=($menuitem)
			echo "deploying to ${target[0]}"
			/badge/admin/honeydb_pull.sh ${target[0]}
			pause
			break
		fi
	done

	rm $RD/hnpo.txt
}

function mesh_honeydb_pull {
	clear
	echo "please wait, running tasks in parallel"
	/badge/admin/honeydb_pull_all.sh | tee $RD/hdbpa.txt
	dialog --clear --begin 0 0 --no-collapse --exit-label "$LABELEXIT" --title "DEPLOY: $ESSID" --textbox $RD/hdbpa.txt $MAXRES
}

function mesh_honeylogs_pull {
	clear
	echo "please wait, running tasks in parallel"
	/badge/admin/honeylogs_pull_all.sh | tee $RD/hdbpa.txt
	dialog --clear --begin 0 0 --no-collapse --exit-label "$LABELEXIT" --title "DEPLOY: $ESSID" --textbox $RD/hdbpa.txt $MAXRES
}


function mesh_init {
	dialog --begin 0 5 --no-collapse --title "RESET ALL" --no-tags --defaultno --yes-button "yes" --no-button "NO"  --yesno "reset ALL configurations and scoring? if yes, badges will restart." 0 0
	
	ret=$?
	case "$ret" in
		0) echo "ERASING ALL";
			clear
			if [ -f /badge/admin/flash_on_update.txt ]; then
				$PA/badge_mesh_exec_bg.sh "$PA/badge_update_flash.sh"
			fi
			$PA/badge_mesh_exec_bg.sh "$P/badge_erase.sh;$P/reboot.sh";;
		1) ;; # no
		*) exit ;;
	esac
}

function mesh_versions {
	clear
	echo "please wait, running tasks in parallel"
	$PA/badge_mesh_version_bg.sh | column -c 40 -x -s " " -t | sort | tee $RD/bmv.txt
	dialog --clear --begin 0 0 --no-collapse --exit-label "$LABELEXIT" --title "VERSiONS: $ESSID" --textbox $RD/bmv.txt $MAXRES
}

function mesh_led_flash {
	clear
	echo "please wait, running tasks in parallel"
	$PA/badge_mesh_exec_bg.sh $P/bling_led_flash.sh
}

function mesh_led_off {
	clear
	echo "please wait, running tasks in parallel"
	$PA/badge_mesh_exec_bg.sh $P/bling_stop_led.sh
}

function mesh_actled {
	clear
	if [ $1 == 'on' ]; then
		echo "enabling act LED on all"
		$PA/badge_mesh_exec_bg.sh "echo 0 > /sys/class/leds/led0/brightness"
	elif [ $1 == 'off' ]; then
		echo "disabling act LED on all"
		$PA/badge_mesh_exec_bg.sh "echo 1 > /sys/class/leds/led0/brightness"
	fi
}

function broadcast_msg_on {
	eval setsid $P/broadcast_msg.sh $SUPPRESS &
	disown
}

function broadcast_time_on {
	eval setsid $P/broadcast_time.sh $SUPPRESS &
	disown
}

function menu_mass {
	while true; do

	bstat_msg=$(pgrep -f "/bin/bash /badge/bin/broadcast_msg.sh")
	if [[ $bstat_msg =~ [0-9] ]]; then
		bstat_msg=off
	else
		bstat_msg=on
	fi

	bstat_time=$(pgrep -f "/bin/bash /badge/bin/broadcast_time.sh")
	if [[ $bstat_time =~ [0-9] ]]; then
		bstat_time=off
	else
		bstat_time=on
	fi

	if [ -f /badge/admin/flash_on_update.txt ]; then
		fou_tog=off
	else
		fou_tog=on
	fi

	if [ -f /badge/admin/lite_addons.txt ]; then
		lite_tog=off
	else
		lite_tog=on
	fi


	# we do not use a mesh network, but was initially intended to be
	dialog --begin 0 18 --no-lines --no-collapse --infobox "`cat /badge/art/sysops.txt`" 17 21 --and-widget --begin 0 0 --no-collapse --title "[ MASS CTRL ]" \
		--no-tags --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --menu "" 14 14 21 \
	mesh_neighbors "mesh nodes" \
	mesh_honeydb_pull_one "honeydb pull" \
	mesh_honeydb_pull "honeydb all" \
	mesh_honeylogs_pull "hnylogs all" \
	mesh_led_flash "LEDs flash" \
	mesh_led_off "all LEDs off" \
	mesh_actled_on "act LED on" \
	mesh_actled_off "act LED off" \
	mesh_broadcast_msg_$bstat_msg "msgcast $bstat_msg" \
	mesh_broadcast_time_$bstat_time "timecast $bstat_time" \
	mesh_flash_leds_$fou_tog "ledonupd $fou_tog" \
	mesh_lite_addons_$lite_tog "lt addon $lite_tog" \
	mesh_versions "get version" \
	mesh_deploy_one "update one" \
	mesh_deploy "update all" \
	mesh_deploy_addons "ul all addons" \
	mesh_deploy_one_addons "ul 1 addons" \
	mesh_reboot "reboot all" \
	mesh_shutdown "power down" \
	mesh_init "init all" 2>"${INPUT}"

	ret=$?
	case "$ret" in
		0) ;;
		1) break ;;
		*) exit ;;
	esac
	
	menuitem=$(<"${INPUT}")

	case $menuitem in
		mesh_neighbors) mesh_neighbors;;
		mesh_led_flash) mesh_led_flash;;
		mesh_honeydb_pull_one) mesh_honeydb_pull_one;;
		mesh_honeydb_pull) mesh_honeydb_pull;;
		mesh_honeylogs_pull) mesh_honeylogs_pull;;
		mesh_led_off) mesh_led_off;;
		mesh_actled_on) mesh_actled on;;
		mesh_actled_off) mesh_actled off;;
		mesh_flash) mesh_flash;;
		mesh_reboot) mesh_reboot;;
		mesh_broadcast_msg_on) broadcast_msg_on;;
		mesh_broadcast_msg_off) kill -9 $(pgrep -f "/bin/bash /badge/bin/broadcast_msg.sh");sleep 2;;
		mesh_broadcast_time_on) broadcast_time_on;;
		mesh_broadcast_time_off) kill -9 $(pgrep -f "/bin/bash /badge/bin/broadcast_time.sh");sleep 2;;
		mesh_flash_leds_on) touch $PA/flash_on_update.txt;;
		mesh_flash_leds_off) rm -f $PA/flash_on_update.txt;;
		mesh_lite_addons_on) touch $PA/lite_addons.txt;;
		mesh_lite_addons_off) rm -f $PA/lite_addons.txt;;
		mesh_versions) mesh_versions;;
		mesh_deploy) mesh_deploy;;
		mesh_deploy_one) mesh_deploy_one;;
		mesh_deploy_addons) mesh_deploy_addons;;
		mesh_deploy_one_addons) mesh_deploy_one_addons;;
		mesh_shutdown) mesh_shutdown;;
		mesh_init) mesh_init;;
		exit) break;;
	esac
	done
}

function cpu_eat {
	clear
	dd if=/dev/zero of=/dev/null &
	ps axuwww | grep zero 
	sleep 3
}

function cpu_eat_stop {
	clear
	killall -9 dd
	sleep 1
	ps axuww | grep zero
	sleep 3
}

function screen_rotate {
	if grep -q "=270" /boot/cmdline.txt; then
		sed -i -e "s/fbtft_device.rotate=[0-9]*/fbtft_device.rotate=90/" /boot/cmdline.txt
	else
		sed -i -e "s/fbtft_device.rotate=[0-9]*/fbtft_device.rotate=270/" /boot/cmdline.txt
	fi
	dialog --clear --title "SCREEN ROTATE" --msgbox "screen rotate complete, please reboot" 0 0
}

function menu_debug {
	while true; do
	dialog --begin 0 18 --no-lines --no-collapse --infobox "`cat /badge/art/sysops.txt`" 17 21 --and-widget --begin 0 0 --no-collapse --title "[ DEBUG ]" \
		--no-tags --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --menu "" 16 8 26 \
	power_off "shutdown" \
	power_rst "reboot" \
	screen_rotate "rotate lcd" \
	mesh_start "join mesh" \
	mesh_stop "exit mesh" \
	kea_dhcp_enable "enbl dhcpcd" \
	kea_dhcp_disable "dsbl dhcpcd" \
	usb0_enable "start usb0" \
	usb0_disable "stop usb0" \
	usb0_toggle "usb0 status" \
	hdmi_enable "start hdmi" \
	hdmi_disable "stop hdmi" \
	iptables_start "start fw" \
	iptables_stop "stop fw" \
	show_debug "screen rez" \
	toggle_ssh "toggle ssh" \
	cpu_eat "eat cpu" \
	cpu_eat_stop "stop eat cpu" \
	honeypot_ssh_start "_hp start SSH" \
	honeypot_ssh_stop "_hp stop SSH" \
	honeypot_wlan0_start "_hp start wlan0" \
	honeypot_wlan0_stop "_hp stop wlan0" \
	honeypot_ap_start "_hp start WAP" \
	honeypot_ap_stop "_hp stop WAP" \
	honeypot_dhcp_start "_hp start DHCP" \
	honeypot_dhcp_stop "_hp stop DHCP" 2>"${INPUT}"

	ret=$?
	case "$ret" in
		0) ;;
		1) break ;;
		*) exit ;;
	esac
	
	menuitem=$(<"${INPUT}")

	case $menuitem in
		power_off) $P/shutdown.sh;;
		power_rst) $P/reboot.sh;;
		menu_mgmtwap) menu_mgmtwap;;
		screen_rotate) screen_rotate;;
		kea_dhcp_enable) kea_dhcp_enable;;
		kea_dhcp_disable) kea_dhcp_disable;;
		mesh_start) mesh_start;;
		mesh_stop) mesh_stop;;
		mesh_neighbors) mesh_neighbors;;
		usb0_enable) usb0_enable;;
		usb0_disable) usb0_disable;;
		usb0_toggle) usb0_toggle;;
		hdmi_enable) hdmi_enable;;
		hdmi_disable) hdmi_disable;;
		iptables_start) iptables_start;;
		iptables_stop) iptables_stop;;
		toggle_ssh) toggle_ssh;;
		cpu_eat) cpu_eat;;
		cpu_eat_stop) cpu_eat_stop;;
		honeypot_status) honeypot_status;;
		honeypot_wlan0_start) honeypot_wlan0_start;;
		honeypot_wlan0_stop) honeypot_wlan0_stop;;
		honeypot_ssh_start) honeypot_ssh_start;;
		honeypot_ssh_stop) honeypot_ssh_stop;;
		honeypot_dhcp_start) honeypot_dhcp_start;;
		honeypot_dhcp_stop) honeypot_dhcp_stop;;
		honeypot_ap_start) honeypot_ap_start;;
		honeypot_ap_stop) honeypot_ap_stop;;
		show_debug) show_debug;;
		exit) break;;
	esac
	done

}

function friends_list {
	if [ -f "$DATA_FRIENDS" ]; then
		l=$(cat $DATA_FRIENDS | wc -l)
		w=$(cat $DATA_FRIENDS | wc -L)
		let l=$l+6
		let w=$w+9
		dialog --clear --begin 0 0 --no-collapse --exit-label "$LABELEXIT" --title "FRiENDS" --textbox "$DATA_FRIENDS" $l $w
	else
		dialog --clear --begin 0 9 --title "FRiENDS" --msgbox "no friends, go find some!" 0 0
	fi
}

function friends_menu {
	while true; do
	dialog --begin 0 18 --no-lines --no-collapse --infobox "`cat /badge/art/sysops.txt`" 17 21 --and-widget --begin 0 0 --no-collapse --title "[ FRiENDS ]" \
		--no-tags --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --menu "" 10 6 2 \
	friends_list "list friends" \
	friends_make "make friends" 2>"${INPUT}"

	ret=$?
	case "$ret" in
		0) ;;
		1) break ;;
		*) exit ;;
	esac
	
	menuitem=$(<"${INPUT}")

	case $menuitem in
		friends_list) friends_list;;
		friends_make) friends_make;;
		exit) break;;
	esac
	done
}

function friends_make {
	if [[ $HANDLE =~ ^NPC.* ]]; then
		dialog --begin 0 5 --ok-label "$LABELOK" --msgbox "your handle must not begin with NPC.  please configure in setup." 0 0
		return 1
	fi

	let i=0
	W=()
	max=0
	while read -r line; do
		if [ ${#line} > $max ]; then
			max=${#line} 	
		fi
    let i=$i+1
    W+=($line "$line")
	done < <( /badge/bin/badge_mesh_list.sh | egrep -v " NPC.*$" | awk '{print $2 "(" $1 ")" }' )

	if [ $i -eq 0 ]; then
		dialog --begin 0 3 --title "NEARBY" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --msgbox "no badges nearby with configured handles.  i.e. handle is not a default NPC* handle." 0 0
		return 1
	fi

	let tot=$i+6
	let max=$max+6

	dialog --title "NEARBY" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --menu "" $tot $max $i "${W[@]}" 2>"${INPUT}"

  ret=$?

  case "$ret" in
    0) ;;
    1) return 1;;
    *) break;;
  esac

  menuitem=$(<"${INPUT}")

	if [[ $menuitem =~ ^[A-Za-z0-9]{1} ]]; then
		target=$(echo "$menuitem" | sed 's/(.*//g')
  	clear
		tput civi
		echo -n "hello $menuitem..."
		avahi-publish -d $AVAHI -H $HANDLE.$AVAHI -s $HANDLE _COMMS._udp 5300 "FRIENDME:$target" &
		sleep=0
		while [ $sleep -lt 6 ]; do
			echo -n "."
			let sleep+=1
			sleep 1
		done
		
		snagged=$(avahi-browse -atrp -d $AVAHI | egrep "FRIENDME:$HANDLE\"$" | sed 's/;/ /g' | awk '{print $4}')
		echo ""
		if [ "$target" == "$snagged" ]; then
			echo "you are now friends with $menuitem!"
			grep -qxF "$menuitem" $DATA_FRIENDS || echo "$menuitem" >> $DATA_FRIENDS
		else
			echo "friendship failure"
		fi
		sleep 3
		killall avahi-publish
		pause
	else
		dialog --clear --begin 0 0 --no-collapse --title "FAiLED" --msgbox "can't make friends with $menuitem" 0 0
	fi
}

function badge_init {
	dialog --begin 5 5 --no-collapse --title "RESET ALL" --no-tags --defaultno --yes-button "yes" --no-button "NO"  --yesno "reset ALL configurations and scoring? if yes, badge will restart." 0 0
	
	ret=$?
	case "$ret" in
		0) $P/badge_erase.sh;$P/reboot.sh;;
		1) ;; # no
		*) exit ;;
	esac
}

function menu_system {

	while true; do

  $P/prune_msgs.sh

	newmsgs=$(ls 2>/dev/null -Ubad1 -- $DATA_MSGS/NEW_*.txt | wc -l)
	if [[ $newmsgs > 0 ]]; then
		msgs="($newmsgs)"
	else
		msgs=""
	fi

	dialog --begin 0 17 --no-lines --no-collapse --infobox "`cat /badge/art/sysops.txt`" 17 21 --and-widget --begin 0 0 --no-collapse --title "[ BADGE OPS ]" \
		--no-tags --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --menu "" 11 8 12 \
	show_me "user info" \
	friends_menu "friends" \
	show_scorecard "your stats" \
	read_msgs "messages$msgs" \
	mesh_neighbors "nodes near" 2>"${INPUT}"

	ret=$?
	case "$ret" in
		0) ;;
		1) break ;;
		*) exit ;;
	esac
	
	menuitem=$(<"${INPUT}")

	case $menuitem in
		show_me) show_me;;
		friends_menu) friends_menu;;
		show_inbound) show_inbound;;
		read_msgs) read_msgs;;
		show_scorecard) show_scorecard;;
		mesh_neighbors) mesh_neighbors;;
		badge_init) badge_init;;
		exit) break;;
	esac
	done
}

function read_msgs {
	while true; do

  $P/prune_msgs.sh

	let i=0
	W=()
	while read -r line; do
		((i++))
    W+=($line "$line")
	done < <( find $DATA_MSGS/*.txt -maxdepth 1 -type f | sort | sed 's/\/badge\/data\/messages\///g' | sed 's/\.txt$//g')

	let tot=$i+6
	if [ "$tot" -gt "15" ]; then tot=15; fi

	dialog --begin 0 0 --title "MESSAGES" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --menu "" $tot 17 $i "${W[@]}" 2>"${INPUT}"

  ret=$?

  case "$ret" in
    0) ;;
    1) break ;;
    *) exit ;;
  esac

  menuitem=$(<"${INPUT}")

	if [ $? -eq 0 ]; then
		if [[ $menuitem =~ ^NEW_ ]]; then
			minew=$(sed 's/^NEW_//' <<< $menuitem)
			fold -w 36 -s $DATA_MSGS/$menuitem.txt > $DATA_MSGS/$minew.txt
			rm $DATA_MSGS/$menuitem.txt
			menuitem=$minew
		fi
		dialog --clear --begin 0 0 --no-collapse --exit-label "$LABELEXIT" --title "MSG: $menuitem" --textbox $DATA_MSGS/$menuitem.txt $MAXRES
	fi

	done

}

function exit_lol {
	systemctl stop badge_button_handler_main_menu
	#systemctl start badge_button_handler_konami
	status_ticker_stop
	clear
	tput cnorm
	echo "GO!"
	sleep .2
	clear
	echo "[menu] exiting..."
	echo -n "root@badge:~# "
	$P/button_handler_konami.py
	#sleep 6
	echo " "

	#echo "lol jk" | figlet -f smslant
	sleep .5
	systemctl stop badge_button_handler_konami
	systemctl start badge_button_handler_main_menu
	tput civis
}

function status_ticker_start {
  cur_wlan0_status=$(ifconfig wlan0 | grep inet | awk '{print $2}')
  if [ "$cur_wlan0_status" == "$HONEYIP" ]
	then
		# honeypot is likely running
		status_ticker_main_stop
		status_ticker_honey_start
  else
		# honeypot is likely not running
		status_ticker_main_stop
		status_ticker_main_start
	fi
}

function status_ticker_stop {
	status_ticker_main_stop
	status_ticker_honey_stop
}

function status_ticker_honey_start {
	$P/badge_status_ticker_honey.sh &
}

function status_ticker_main_start {
	$P/badge_status_ticker_main.sh &
}

function menu_addons {
	while true; do
	let i=0
	W=()
	while read -r line; do
    let i=$i+1
    W+=($line "$line")
	done < <( find /badge/addons/addon_*.sh -maxdepth 1 -type f | sort | sed 's/\/badge\/addons\/addon_//g' | sed 's/\.sh$//g')

	let tot=$i+6

	if [ "$tot" -gt "15" ]; then tot=15; fi

	dialog --begin 0 0 --title "ADD-ONS" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --menu "" $tot 17 $i "${W[@]}" 2>"${INPUT}"

  ret=$?

  case "$ret" in
    0) ;;
    1) break ;;
    *) exit ;;
  esac

  menuitem=$(<"${INPUT}")

	if [ $? -eq 0 ]; then
  	clear
		tput civis
		echo "running addon $menuitem"
		sleep 1
		clear
		status_ticker_stop
		/badge/addons/addon_$menuitem.sh
		tput civis
		pause
		status_ticker_start
	fi
	done
}

function menu_unlocks {
	if [ ! "$(ls -A /badge/data/unlocks/)" ]; then
		dialog --clear --begin 0 0 --no-collapse --title "UNLOCKS" --msgbox "nothing has been unlocked, why not try dropping to a shell?  no qwerty keyboard required." 7 40
		return
	fi

	while true; do
		let i=0
		W=()
		while read -r line; do
    	let i=$i+1
    	W+=($line "$line")
		done < <( find /badge/data/unlocks/*.sh -maxdepth 1 -type f | sort | sed 's/\/badge\/data\/unlocks\///g' | sed 's/\.sh$//g')

		let tot=$i+6

		dialog --begin 0 0 --title "UNLOCKED" --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --no-tags --menu "" $tot 17 $i "${W[@]}" 2>"${INPUT}"

 	 ret=$?

 	 case "$ret" in
	    0) ;;
	    1) break ;;
 	   *) exit ;;
	  esac

 	 menuitem=$(<"${INPUT}")

		if [ $? -eq 0 ]; then
 		 	clear
			tput civis
			echo "running unlocked secret $menuitem"
			status_ticker_stop
			/badge/data/unlocks/$menuitem.sh
			pause
			status_ticker_start
		fi
	done
}

function status_ticker_main_stop {
	pkill -9 -x -f "/bin/bash /badge/bin/badge_status_ticker_main.sh"
}

function status_ticker_honey_stop {
	pkill -9 -x -f "/bin/bash /badge/bin/badge_status_ticker_honey.sh"
}


function pause {
		echo ""
		echo "$PAUSE"
		read -rsn1
}

# start up battery status monitor
if pgrep -x "check_bat.sh" >/dev/null; then
  pkill -9 -x -f "/bin/bash /badge/bin/check_bat.sh"
else
	$P/check_bat.sh &
fi

### MAIN LOOP
while true
do

	status_ticker_start

	# these 2 unlockables are the only addons that will end up on the main menu
	menu_total=13
	if [ -f '/badge/data/unlocks/debug.sh' ]; then
		dyn_db='menu_debug _debug'
		((menu_total++))
	fi

	if [ -f '/badge/data/unlocks/admin.sh' ]; then
		dyn_admin='menu_mass _admin'
		((menu_total++))
	fi

	infobox=$(cat /badge/art/btv.txt)
	dialog --begin 0 22 --keep-window --no-lines --no-collapse --infobox "$infobox" 17 21 \
		--and-widget --begin 0 0 --no-collapse --title "[ MAiN ]" \
		--no-tags --keep-window --cancel-button "$LABELCANCEL" --ok-button "$LABELOK" --menu "" $menu_total 11 9 \
	menu_bling "bling" \
	menu_honeypot "honeypot" \
	menu_system "badge" \
	menu_setup "setup" \
	menu_addons "add-ons" \
	menu_unlocks "unlocked" \
	$dyn_admin \
	$dyn_db \
	menu_about "help" 2>"${INPUT}"

	ret=$?

	case "$ret" in
		0) ;;
		1) exit_lol ;;
		*) exit_lol ;;
	esac

	menuitem=$(<"${INPUT}")

	# ADD MENU ITEMS HERE 2/2
	case $menuitem in
		menu_bling) menu_bling;;
		power_off) $P/shutdown.sh;;
		menu_setup) menu_setup;;
		debug) show_debug;;
		ap_menu) menu_ap;;
		menu_honeypot) menu_honeypot;;
		menu_system) menu_system;;
		menu_addons) menu_addons;;
		menu_unlocks) menu_unlocks;;
		menu_debug) menu_debug;;
		menu_mass) menu_mass;;
		menu_about) menu_about;;
		exit) tput cup 16 0 > $CONSOLE;echo -n "restarting menu..."; exit;;
	esac

done

[ -f $INPUT ] && rm $INPUT
