#!/bin/bash
# Spit out details of a .apk package to leafpad.
# Giles R. Greenway 05/2015
apk=$(zenity --file-selection --filename=$HOME/ --title="Choose a .apk file.")
cd /tools/androguard
info=$(./androapkinfo.py -i "$apk")
echo "$info" | leafpad
