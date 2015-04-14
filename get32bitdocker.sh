#!/bin/bash

# Script to build a 32-bit version of Docker, eventually.
# Gratefully stolen from: http://blenderfox.com/2014/09/14/building-docker-io-on-32-bit-arch/ 

# Run this on a VirtualBox installation of the 32-bit version of Ubuntu 14.04 Trusty:
# http://releases.ubuntu.com/14.04/
# http://releases.ubuntu.com/14.04/ubuntu-14.04.2-server-i386.iso

lxc-stop -n Ubuntu
lxc-destroy -n Ubuntu

ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -P password

# We need the last two packages to build images.
apt-get install -y --force-yes git lxc sshpass aufs-tools cgroup-bin

# Docker wants installing in a Docker container. Trick it with a Linux container.
# This is going to take a while.
lxc-create -n Ubuntu -t ubuntu — –release trusty –arch i386 –auth-key $HOME/.ssh/id_rsa.pub
lxc-start -n Ubuntu -d

# Find the IP address of the container.
while [ $(lxc-info -n Ubuntu | grep IP: | sort | uniq | unexpand -a | cut -f3 | wc -l) -lt 1 ];
do
sleep 1s
lxc-info -n Ubuntu | grep IP:
done
IP=$(lxc-attach -n Ubuntu -- ifconfig | grep 'inet addr' | head -n 1 | cut -d ':' -f 2 | cut -d ' ' -f 1)

echo Main IP: $IP

echo Pushing dockerCompile.sh to IP $IP
sshpass -p 'ubuntu' scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa $HOME/DroidDestructionKit/dockerCompile.sh ubuntu@$IP:/home/ubuntu
while [ $? -ne 0 ]
do
sshpass -p 'ubuntu' scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa $HOME/DroidDestructionKit/dockerCompile.sh ubuntu@$IP:/home/ubuntu
done

# Run the compile script.
lxc-attach -n Ubuntu '/home/ubuntu/dockerCompile.sh'

mkdir -p $HOME/build

# Get the tarred binaries out of the container.
sshpass -p 'ubuntu' scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa ubuntu@$IP:/home/ubuntu/docker*.txz $HOME/build

cd $HOME/build
tar -xJf docker_*dev.txz
cd *dev/binary

cp docker /usr/bin
docker -d &

# Save a bit of space trashing the container.
lxc-stop -n Ubuntu
lxc-destroy -n Ubuntu
rm -rf /var/cache/lxc/trusty


