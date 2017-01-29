
Welcome to the "Droid Destruction Kit", (DDK) a collection of tools in a virtual machine
for the reverse-engineering and network
traffic analysis of Android apps. Unlike more complete and polished tools like Santuku and Kali Linux,
the emphasis is on granting techicnal novices some insight and agency into what their devices are doing,
rather than malware analysis or exploit development.

You will need:
Oracle VirtualBox installed on your computer
The VirtualBox appliance .ova file that contains the tools
A Google account (preferably one you don't use day-to-day)
An Android device (for the latter stages)
An unlocked and rooted Android device (for the very latter stages)

Unlocking and rooting Android devices can be tricky, and can cause damage if done incorrectly. How to do this
is beyond the scope of this document.

Getting Started

Start VirtualBox. From the "file" menu, choose "import appliance" and select the ".ova" file you downloaded.
Click the green arrow to start the virtual machine (VM). It will appear in a window, and ask you to login.
Give the username "root" and the password "ddk". The program the VM is running that sends and recieves text
is called a terminal, the program behind it that listens for and responds to commands is called a shell.
You have logged in as "root", a user account allowed to do anything to the system.

To start the tools, enter "./ddk" and hit return. What you have just done is run a script. A script
is just a list of commands to be run, or executed by the shell. The "./" means that we should run
the script called "ddk" in our current position in the VM's filesystem. The script contains only
one command:

docker run --rm -i -t -p 8000:8000 -p 6080:6080 -p 8080:80 --privileged -v /dev/bus/usb:/dev/bus/usb ddk

We have used a tool called docker to run a "container", a mostly autonomous part of the system that
acts like another computer, a sort of virtual machine inside another virtual machine. The container
comes from a pre-built "image". A "dockerfile" contains instructions on how to build i You are now
looking at a command prompt for a shell running inside the container. Be warned that if you shut down
the VM, the container will die, anf you'll lose anything inside it.

Clauses like "-p 8080:80" are interesting as they give us an introduction to TCP ports. Packets of information
travelling between computers under a given *protocol*, like HTTP (normal web traffic) have a specific
port as their source and destination. For HTTP, the usual port is 80. "http://www.kcl.ac.uk" is
really short-hand for "http://www.kcl.ac.uk:80", but the "80" is implied, so you don't need to add it.
Port 443 is for encrypted web traffic, using SSL, where the address in your browser starts with "https".
"https://www.kcl.ac.uk" is the short form of "https://www.kcl.ac.uk:443". When we spy on apps' network
traffic later, if they transmit any personal details, they *should* be using SSL. They won't all!
In our case, the VM has been set up to listen for network traffic on port 8080, Docker then passes this
to port 80 inside the container.

Visit "http://localhost:8080" and see what's there.

