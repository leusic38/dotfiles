#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybari3left.log /tmp/polybari3right.log
polybar i3left >>/tmp/polybari3left.log 2>&1 &
polybar i3right >>/tmp/polybari3right.log 2>&1 &

echo "Bars launched..."
