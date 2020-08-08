#! /usr/bin/env sh

read -s -p "Enter Password for sudo: " sudoPW
echo $sudoPW |sudo openvpn ~/openVpnConfig/pfSense-UDP4-1194-efarcis-c &

/usr/NX/bin/nxplayer &
