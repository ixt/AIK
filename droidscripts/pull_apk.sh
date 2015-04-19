#!/bin/bash
# Pull an Android .apk package from a connected device.
# Giles R. Greenway 04/2015

pkg=$( adb shell "su -c 'ls data/app' " | grep -P -o "^[a-zA-Z0-9\.]+" | zenity --list --column=Package ) 
if [ -v "$pkg"]
then
        echo Nothing selected.
        exit 0
fi
echo $pkg
# http://stackoverflow.com/questions/26746853/strange-behaviour-of-adb-pull-in-bash-script
apk=$(adb shell "su -c 'ls data/app/*.apk '" | grep "$pkg" | tr -d '\r')
echo $apk
file=$(zenity --file-selection --directory --filename=$HOME)
echo $file
if [[ -w $FILE ]]
then
        cd $file
        adb pull $apk
else
        zenity --error --text="$file is not writeable."
fi
