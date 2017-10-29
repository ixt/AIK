#!/bin/bash
# Pull the sqlite database from an app.
# Giles R. Greenway 08/2015
adb shell "su -c 'mount -o rw,remount /system' "
pkg=$( adb shell "su -c 'ls data/data' " | grep -P -o "^[a-zA-Z0-9\.]+" | zenity --list --column=Package ) 
if [ -v "$pkg" ]
then
        echo Nothing selected.
        exit 0
fi
echo Package: $pkg
# http://stackoverflow.com/questions/26746853/strange-behaviour-of-adb-pull-in-bash-script
db=$(adb shell "su -c 'ls data/data/$pkg/databases ' " | tr -d '\r' ) 
echo Databases: echo $db
mkdir -p $HOME/Databases/$pkg
cd $HOME/Databases/$pkg
for f in $db
do
    echo $f
    adb shell "su -c 'cp /data/data/$pkg/databases/$f /sdcard' "
    adb pull /sdcard/$f $HOME/Databases/$pkg
        adb shell "su -c 'rm /sdcard/$f' "
done