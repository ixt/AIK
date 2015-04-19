#!/bin/bash
# Use adb to take a screenshot, then display it with GPicView
# http://blog.shvetsov.com/2013/02/grab-android-screenshot-to-computer-via.html
# Giles R. Greenway 04/2015
png=$(zenity --file-selection --save --filename=/home/$USERNAME/screenshots/screenshot.png --title="Save a screenshot as a .png")
case $? in
         0)
                adb shell screencap -p | perl -pe 's/\x0D\x0A/\x0A/g' > $png; gpicview $png;;
         1)
                echo "No file selected.";;
        -1)
                echo "An unexpected error has occurred.";;
esac
