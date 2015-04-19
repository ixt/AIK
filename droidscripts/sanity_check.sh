#!/bin/bash
# Execute the passed command if a rooted device with USB debugging is connected.
# Giles R. Greenway 04/2015

# Are we connected?
con=$( adb devices | grep -v "^List" ) 
if [ -z "$con" ]
then
    zenity --error --text="No device Found!"
    exit 0
fi

# Is USB debugging enabled?
adb shell "ls" > /dev/null
if [ "$?" != "0" ]
then
    zenity --error --text="Is USB debugging enabled?"
    exit 0
fi

# Are we rooted?
rt=$( adb shell "su -c 'ls /system' " | grep not\\sfound ) 
if [ -n "$rt" ]
then
    zenity --error --text="This device isn't rooted!"
    exit 0
fi

$1
