#!/bin/sh

if [ $(xset -q | grep 'Standby: 20 ' | wc -l) -gt 0  ]; then
    xset dpms 240
else
    xset dpms 20
fi
