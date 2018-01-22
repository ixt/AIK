
# Wireshark

What follows is rather complicated and requires a rooted 'phone, not just USB debugging enabled. Network traffic to and from the 'phone will be passed
to the virtual machine via USB, and analysed with a program called [Wireshark](https://www.wireshark.org/). On the 'phone, network traffic will be
captured using a utility called [TCPdump](http://www.tcpdump.org/). This is common on most Linux distributions, but is often not provided by default
on Android devices. The source-code must be cross-compiled into an exectutable binary suited for the ARM processors used by most 'phones. The traffic
is sent and recieved by the [netcat](http://nc110.sourceforge.net/) utility, which must be present on both the 'phone and the virtual machine. Again,
this must be compiled as an ARM binary from source. Ensuring that all the utilities are present, and running them on both the 'phone and the virtual
machine is done by selecting the "Wireshark via Netcat" option from the "Android Device Tools" menu. Ensure the 'phone has a network connection,
and is connected via USB debugging. Run an app, and see what happens.

![TheLineKeepIn Wireshark](/img/line_ws2.png)

We can see "TheLineKeepin" connecting to a variety of services in quick succession. Wireshark takes a little "getting the hang of", there
are some decent [tutorials](http://www.linuxjournal.com/content/monitoring-android-traffic-wireshark). Here,
the column options have been set to resolve raw IP addresses into something more readable, and a filter to view only HTTP traffic has been
applied. Often the there are many nearly identical games with nearly identical names. Consider
["Dont Tap The WhiteTile"](https://play.google.com/store/apps/details?id=com.umonistudio.tile&hl=en_GB) and
["Tapi Duel: Dont Tap White Tile"](https://play.google.com/store/apps/details?id=com.kukolab.tapiduel&hl=en).
(They look remarkably similar, can we tell how much code they "share"?)

![WhiteTile WireShark](/img/whitetile_ws2.png)

The latter transmits some data in JSON format. Where have we seen this number before?

![WhiteTile JSON](/img/whitetile_ws1.png)

If you enter "*#06*" into your 'phone's dialler, you get your 'phone's IMEI number, which the game
has been transmitting in unencrypted plain-text.

![MotoG IMEI](/img/moto_imei.png)

This is contrary to [best practice](https://developer.android.com/training/articles/user-data-ids.html), but other services
may be using it as a unique user ID. Are the apps in this [blog post](https://scotthelme.co.uk/trusting-security-in-smartphone-apps/) still
behaving as badly? The absolute prize for "the worst data transmitted in plain-text" must surely go to
[Refugee Info](https://play.google.com/store/apps/details?id=info.refugee.app&hl=en) by the [International Rescue Committee](https://www.rescue.org/).
It's cleaned up its act now, but it *was* transmitting lattitude and longitude unencrypted.

![Refugee Info](/img/ref_info.png)