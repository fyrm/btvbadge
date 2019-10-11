wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf &
dhclient -d -i wlan0
