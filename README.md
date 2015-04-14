DroidDestructionKit
===================

The DroidDestructionKit is a Docker image to help beginners reverse engineer Android apps and examine their network traffic. It is intended
to be distributed with a VirtualBox appliance.

So that as many people can use it as possible, we prefer that it is built on 32-bit virtual machines. Docker doesn't officially support
32-bit machines, but it is possible, as shown by the work of ["Blender Fox"](http://blenderfox.com/2014/09/14/building-docker-io-on-32-bit-arch/).
Start by installing the 32-bit i386 version of [Ubuntu Server 14.04 Trusty](http://releases.ubuntu.com/14.04/) on VirtualBox.

Building the 32-bit version of Docker will take a while:
```
git clone https://github.com/kingsBSD/DroidDestructionKit.git
sudo ./DroidDestructionKit/get32bitdocker.sh 
```

Then you can build the image and start the container:
```
sudo sudo docker build -t ddk DroidDestructionKit/
docker run -i -t -p 6080:6080 --privileged -v /dev/bus/usb:/dev/bus/usb ddk
```

Play with the tools via the VNC Desktop: http://127.0.0.1:6080/vnc.html

<img src="https://raw.githubusercontent.com/kingsBSD/DroidDestructionKit/master/screenshots/ddk_demo.png"/>


