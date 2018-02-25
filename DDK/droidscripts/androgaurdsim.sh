#!/bin/bash
# Find the similarity of two .apk packages.
# Giles R. Greenway 05/2015
filea=$(zenity --file-selection --filename=$HOME --title="Choose the first .apk file.")
fileb=$(zenity --file-selection --filename=$HOME --title="Choose the second .apk file.")
cd /tools/androguard
sim=$(./androsim.py -i $filea $fileb | grep -P -o [0-9.]+%)
zenity --info --text="$sim similar"


