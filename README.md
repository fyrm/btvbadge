# DEF CON 27 Blue Team Village Badge #

Full badge write-up, media, badge candy and updates (1/2):
<https://fyrmassociates.com/blog/2019/06/08/defcon-27-blue-team-village-badge/>

Badge wrap-up post (2/2):
<https://fyrmassociates.com/blog/2019/10/10/defcon-27-blue-team-village-badge-wrapup/>

# Writing Addons #

The idea behind an addon (not to be confused with the SAO hardware standard) is to extend badge functionality in a slightly cleaner fashion than modifying existing spaghetti^H^H^H^H^H^H^H^H^H code.

Addons are simply shell scripts placed in /badge/addons/.  The filename must be addon_name.sh, where "name" will be displayed on the badge's addon menu.  There are a few simple ways to get the addon onto the badge (wifi, USB, SD card), all detailed within the help docs directly on the badge itself.  As the badge is based on Raspbian, expect a very Debian-like experience.

An addon is ideally a shell script or other executable that runs natively on Raspbian in console mode (no X) that does not require any additional packages, but there is no reason an addon cannot come bundled with the relevant .dpkg files or other files to install prior to execution.

## Input in Addons ##
A button handler maps D-pad switch presses to arrow keys.  "B" and "A" are the two right-most switches on the badge face and are mapped to enter and tab keys respectively.  "dialog" uses these keys for navigation.  It is easiest for the addon to use these keys as input.  Otherwise, you'll need to stop the menu button handler with:

`systemctl stop badge_button_handler_main`

..and then restart it when the addon is finished running with

`systemctl start badge_button_handler_main`

An example button handler is provided in `/badge/bin/badge_button_handler_test.py`

## Output in Addons ##
The badge runs in runlevel 3, text mode.  The color display is 320x240 with a default font allowing for of 40x17 characters.  Writing data to the last two rows on the screen in an addon should be avoided, as they are used for displaying status messages (honeypot, BTV official or nearby nodes).  It is better to plan on the addon using 40x15 and leaving the last 2 rows blank.

## Network and communication addons ##
By default, each badge joins "badgenet", a WiFi network.  This allows for official BTV announcements, communications with other badges, "pairing" with others, and generally giving a base network to extend functionality and opportunities for interesting hacks.

It is not a mesh network, despite comments, filenames or functions named as such.  To leave badgenet, either disable via TUI menu or run:

`/badge/bin/badge_mesh_stop.sh`

To join a wifi network, edit /etc/wpa/wpa_supplicant.conf with the SSID, PSK and execute:

`/badge/bin/start_wifi.sh`

To exit the wifi network, kill wpa_supplicant, dhclient and run

`/badge/bin/badge_mesh_start.sh`

## Addon Ideas ##
* tail log_all_simple.txt (honeypot log) to screen, flash LEDs on any new honeypot connections
* Custom bling modes (write directly to framebuffer /dev/fb1, or use tput)
* Avahi - abusing service broadcasts as a comms channel (*cough* the badge might already be doing that)
* Interfacing with hardware SAOs over i2c
* Joining the badge to the DefCon-Open WiFi network when in honeypot mode at your own risk
* Running a game console emulator
* Joining the BLE mesh network used by other unofficial badges

# License #

Licensed under GPL v3.0

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

Some parts also covered under CC BY-SA 3.0
