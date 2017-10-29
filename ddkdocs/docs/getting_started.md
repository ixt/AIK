


# Getting Started

Start VirtualBox. From the "file" menu, choose "import appliance" and select the ".ova" file you downloaded.
Click the green arrow to start the virtual machine (VM). It will appear in a window, and ask you to login.
Give the username "root" and the password "ddk". The program the VM is running that sends and recieves text
is called a terminal, the program behind it that listens for and responds to commands is called a shell.
You have logged in as "root", a user account allowed to do anything to the system.

![Vbox terminal](img/ddk_container.png)

To start the tools, enter `./ddk` and hit return. What you have just done is run a script. A script
is just a list of commands to be run, or executed by the shell. The "./" means that we should run
the script called "ddk" in our current position in the VM's filesystem. The script contains only
one command:

```
docker run --rm --name alp -d -p 8080:8080 -p 8000:8000 -p 7000:7000 --privileged -v /dev/bus/usb:/dev/bus/usb ddk
```

We have used a tool called docker to run a "container", a mostly autonomous part of the system that
acts like another computer, a sort of virtual machine inside another virtual machine. The container
comes from a pre-built "image". A "dockerfile" contains instructions on how to build i You are now
looking at a command prompt for a shell running inside the container.

Clauses like "-p 8080:8080" are interesting as they give us an introduction to TCP ports. Packets of information
travelling between computers under a given *protocol*, like HTTP (normal web traffic) have a specific
port as their source and destination. For HTTP, the usual port is 80. [http://www.kcl.ac.uk](http://www.kcl.ac.uk) is
really short-hand for [http://www.kcl.ac.uk:80](http://www.kcl.ac.uk:80), but the "80" is implied, so you don't need to add it.
Port 443 is for encrypted web traffic, using SSL, where the address in your browser starts with "https".
[https://www.kcl.ac.uk](https://www.kcl.ac.uk) is the short form of [https://www.kcl.ac.uk:443](https://www.kcl.ac.uk:443). When we spy on apps' network
traffic later, if they transmit any personal details, they *should* be using SSL. They won't all!
In our case, the VM has been set up to listen for network traffic on port 7000, 8000 and 8080.

Visit [http://localhost:7000](http://localhost:7000) to read these docs offline.

The web-based Linux desktop that contains the tools is at: [http://localhost:8080](http://localhost:8080/vnc.html).

You can download and upload files from and to the VM at: [http://localhost:8000](http://localhost:8000).

[Android Packages](apk.md)
