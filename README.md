DroidDestructionKit
===================

The DroidDestructionKit is a Docker image to help beginners reverse engineer Android apps and examine their network traffic.


Build the container:

```
git clone https://github.com/ixt/DroidDestructionKit.git
./build-ddk
```

Run the container:
```
./ddk
```

Play with the tools via the VNC Desktop: http://127.0.0.1:6080/vnc.html

<img src="https://raw.githubusercontent.com/kingsBSD/DroidDestructionKit/master/screenshots/ddk_demo.png"/>

Set up ADB using webadb hosted on http://127.0.0.1:8001/webadb.js-master/tcpip.html  

Then connect adb with your devices IP found usually in 
Settings -> About Phone -> Status -> IP address

```
adb connect DEVICE_IP:5555
```



Tools:
======

Android SSL Killer:
This allows us to get more access to traffic packets by getting round some of the encryption brought on by the device. This package may not work on some devices due to changes in Android. 

Androgaurd:
A group of tools that are focused on reverse engineering of Android apps.

Burpsuite:
A group of tools that are focused on testing the security of web applications.

Dex2Jar:
Application for decompiling android .dex files to more human readable java .jar files

Drozer:
Application used for sharing, browsing and utilizing exploits that are in the Android operating system 

SQLLite Browser:
Application for browsing SQL databases.

Wireshark:
Application for inspecting packets of data, mostly used for network & web traffic analysis but very versitile for almost any network protocol. 

Glossary:
=========

dalvik: 
The now discontinued virtual machine that allows android to run applications at the user layer without much risk to access the lower level linux kernel. Replaced by ART (Android RunTime) which is fulfils the same function, although in different ways. Dalvik and ART fully compiles the part-compiled (bytecode) dex files into machine code for the device to execute. Dalvik compiles when the application is ran, where as ART compiles when the application is installed.

.dex files:
dalvik executable files

.jar files:
A file containing java source code, these files are often obfuscated to hide what has be programmed usually by using non-specific names for functions and values.

VPN/Reverse Tether:
VPN, Virtual Private Networks, are a method of routing network traffic through another computer, mostly used to access computers on networks that may not be directly exposed to the internet. In our case we use it to redirect all the traffic from an Android device to the researcher's computer. 

