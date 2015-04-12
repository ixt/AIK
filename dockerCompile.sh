#!/bin/bash

# Script to build docker from within a 32-bit Linux container.
# Gratefully stolen from: http://blenderfox.com/2014/09/14/building-docker-io-on-32-bit-arch/ 
# http://blenderfox.com/2014/09/14/building-docker-io-on-32-bit-arch/

# A few extra dependencies are needed to build btfrs-progs.
cd /home/ubuntu echo Installing basic dependencies apt-get update && apt-get install -y aufs-tools automake btrfs-tools e2fslibs-dev libblkid-dev zlib1g-dev liblzo2-dev uuid-dev libacl1-dev build-essential curl dpkg-sig git iptables libapparmor-dev libcap-dev libsqlite3-dev lxc mercurial parallel reprepro ruby1.9.1 ruby1.9.1-dev pkg-config libpcre* --no-install-recommends

# Build Go. Don't hold your breath.
hg clone -u release https://code.google.com/p/go ./p/go
cd ./p/go/src
./all.bash
cd ../../../

export GOPATH=$(pwd)/go
export PATH=$GOPATH/bin:$PATH:$(pwd)/p/go/bin
export AUTO_GOPATH=1

# Apparrently, building lvm and btrfs-progs is a good idea:
# http://blenderfox.com/2014/11/21/docker-io-build-script-update/
git clone https://git.fedorahosted.org/git/lvm2.git
cd lvm2
(git checkout -q v2_02_103 && ./configure --enable-static_link && make device-mapper && make install_device-mapper && echo lvm build OK!) || (echo lvm2 build failed && exit 1)
cd ..

git clone git://git.kernel.org/pub/scm/linux/kernel/git/kdave/btrfs-progs.git
mv btrfs-progs btrfs #Needed to include into Docker code
export PATH=$PATH:$(pwd)
cd btrfs
./autogen.sh
# Shall we not download 0.75Gb of asciidocs dependencies just to build the docs we'll never read?
./configure --disable-documentation
make && echo "btrfs-progs compiled OK!" || (echo "btrfs compile failed" && exit 1)
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$(pwd) #Might not be needed
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$(pwd) #Might not be needed
cd ..

# FINALLY build docker.
git clone https://github.com/docker/docker $GOPATH/src/github.com/docker/docker

cd $GOPATH/src/github.com/docker/docker/
./hack/make.sh binary

# Put the tarred binary where the calling script can find it.
cd $GOPATH/src/github.com/docker/docker/bundles

for d in $(ls -d */ | grep -P -o ".*(?=/)")
do
echo Creating docker.txz
tar -cJvvvvf docker.txz $d
mv *.txz /home/ubuntu
done
