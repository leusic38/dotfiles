#!/bin/sh

# Cycle : 30 s -> 1 min -> 10 min -> 20 min -> 30 s
#
# Deux profils, avec un ordre volontairement different :
#
#   Open space (30 s / 1 min) : verrouillage AVANT extinction de l'ecran.
#   Un ecran noir est donc toujours un ecran verrouille.
#
#   Maison (10 / 20 min) : extinction de l'ecran AVANT verrouillage.
#   Pas de risque, donc on coupe le retroeclairage tot pour la conso, et le
#   mot de passe n'est demande qu'apres une absence reellement longue.
#   A noter : DPMS et le screensaver partagent le meme compteur d'inactivite,
#   remis a zero au moindre input. Un reveil de l'ecran repousse donc le
#   verrouillage -- c'est justement le comportement voulu ici.
#
# xset s <timeout> <cycle>        -> declenche xss-lock (voir xprofile)
# xset dpms <standby> <suspend> <off>  -> extinction de l'ecran
# Sur une dalle LCD, standby coupe deja le retroeclairage : les trois valeurs
# sont alignees, les niveaux suspend/off n'apportent rien de plus.

standby=$(xset -q | awk '/Standby:/{print $2}')

if [ "$standby" -le 30 ]; then
	xset s 55 55
	xset dpms 60 60 60
	notify-send "Verrouillage" "Open space — verrouillage dans 1 min"
elif [ "$standby" -le 60 ]; then
	xset s 1200 1200
	xset dpms 600 600 600
	notify-send "Verrouillage" "Maison — écran dans 10 min, verrouillage dans 20 min"
elif [ "$standby" -le 600 ]; then
	xset s 2400 2400
	xset dpms 1200 1200 1200
	notify-send "Verrouillage" "Maison — écran dans 20 min, verrouillage dans 40 min"
else
	xset s 25 25
	xset dpms 30 30 30
	notify-send "Verrouillage" "Open space — verrouillage dans 30 sec"
fi
