#!/bin/bash
# Pull an Android .apk package from a connected device.
# Giles R. Greenway 04/2015

pkg=$( adb shell "su -c 'ls data/app' " | grep -P -o "^[a-zA-Z0-9\.]+" | zenity --list --column=Package ) 
if [ -v "$pkg"]
then
        echo Nothing selected.
        exit 0
fi
echo Package: $pkg
# http://stackoverflow.com/questions/26746853/strange-behaviour-of-adb-pull-in-bash-script
apk=$(adb shell "su -c 'ls data/app/*.apk '" | grep "$pkg" | tr -d '\r')
echo .apk file: $apk
file=$(zenity --file-selection --directory --filename=$HOME/ --title="Choose a directory to save the .apk file.")
echo Directory: $file
cd $file
adb pull $apk


