#!/bin/bash
# Push an Android .apk package to a connected device.
# Giles R. Greenway 05/2015

file=$(zenity --file-selection --filename=$HOME/ --title="Choose a .apk file.")

case $? in
         0)
                adb install ${file};;
         1)
                echo "No file selected.";;
        -1)
                echo "An unexpected error has occurred.";;
esac
