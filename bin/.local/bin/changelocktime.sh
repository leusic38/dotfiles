#!/bin/sh

standby=$(xset -q | awk '/Standby:/{print $2}')

if [ "$standby" -le 30 ]; then
	xset s 595 595
	xset dpms 600 1200 2400
	notify-send "Verrouillage" "Mise en veille dans 10 min"
elif [ "$standby" -le 600 ]; then
	xset s 1195 1195
	xset dpms 1200 2400 2400
	notify-send "Verrouillage" "Mise en veille dans 20 min"
else
	xset s 25 25
	xset dpms 30 600 1200
	notify-send "Verrouillage" "Mise en veille dans 30 sec"
fi
