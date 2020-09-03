#!/bin/sh

[ -f ~/.xprofile ] && . ~/.xprofile
xrdb -I$HOME ~/.config/Xresources
setxkbmap -layout frqw-option -option grp:ctrls_toggle
eval `$(ssh-agent) -s`
export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit
#exec wmnam LG3

session=${1:dwm}

case $session in
	#i3|i3wm		) exec dbus-launch ssh-agent i3;;
	xfce|xfce4	) exec startxfce4;;
	#bsp|bspwm	) exec dbus-launch ssh-agent bspwm;;
	dwm		) ssh-agent dwmblocks & dwm;;
	*		) exec $session;;
esac

