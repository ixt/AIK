#!/bin/bash
# Run Wireshark via tcpdump/netcat on an Android device.
# http://www.symantec.com/connect/blogs/monitoring-android-network-traffic-part-iv-forwarding-wireshark
# Giles R. Greenway 04/2015

# Do we have netcat?
got_nc=$( adb shell "su -c 'ls /system/xbin' " | grep ^netcat )
if [ -z "$got_nc" ]
then
    echo Pushing netcat to the device
    adb push $DROIDBIN/netcat /storage/sdcard0/
    adb shell "su -c 'cp /storage/sdcard0/netcat /system/xbin; chmod 555 /system/xbin/netcat' "
fi

# Do we have tcpdump?
got_tcpdump=$( adb shell "su -c 'ls /system/xbin' " | grep ^tcpdump )
if [ -z "$got_tcpdump" ]
then
    echo Pushing tcpdump to the device
    adb push $DROIDBIN/tcpdump /storage/sdcard0/
    adb shell "su -c 'cp /storage/sdcard0/tcpdump /system/xbin; chmod 555 /system/xbin/tcpdump' "
fi

adb forward tcp:31337 tcp:31337
adb shell "su -c 'tcpdump -i wlan0 -s 0 -w - -nS | netcat -l -p 31337' " &
adb_pid=$!
echo adb pid: $adb_pid
while [ -v "$(adb shell ps | grep netcat)" ]
do
        echo "Waiting for netcat to start on the device."
        sleep 1
done
nc localhost 31337 | wireshark -i - -kS &
while [ -n "$( ps -e | grep wireshark$)" ]
do sleep 1
done
echo Done with Wireshark.
kill -9 $adb_pid






 
