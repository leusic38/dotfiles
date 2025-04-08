#!/bin/sh

if [ $(xset -q | grep 'Standby: 30 ' | wc -l) -gt 0 ]; then
	xset dpms 600
else
	xset dpms 30
fi
