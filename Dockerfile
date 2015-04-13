
# Gratefully stolen from the 32-bit Ubuntu Docker repos:
# https://github.com/docker-32bit
# https://registry.hub.docker.com/repos/32bit/
FROM 32bit/ubuntu:14.04

# We also want a 32-bit Docker:
# http://blenderfox.com/2014/09/14/building-docker-io-on-32-bit-arch/

MAINTAINER Giles Greenway <giles.greenway@kcl.ac.uk>
# Also gratefully stolen from docker-ubuntu-vnc-desktop:
# https://github.com/fcwu/docker-ubuntu-vnc-desktop
#MAINTAINER Doro Wu <fcwu.tw@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# no Upstart or DBus
# https://github.com/dotcloud/docker/issues/1724#issuecomment-26294856
RUN apt-mark hold initscripts udev plymouth mountall
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        ca-certificates git build-essential libncurses5-dev libssl-dev \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Build adb from source because of the dodginess of distributing Google's binaries...    
#http://www.zdnet.com/article/no-google-is-not-making-the-android-sdk-proprietary-whats-the-fuss-about/    

# Build instructions and Makefiles gratefully stolen from here:
# http://android.serverbox.ch/?p=1217

RUN mkdir -p /tools/adb/system
RUN cd tools/adb/system \
    && git clone -b android-4.4_r1.2 https://android.googlesource.com/platform/system/core \
    && git clone -b android-4.4_r1.2 https://android.googlesource.com/platform/system/extras

RUN mkdir -p /tools/adb/external    
RUN cd /tools/adb/external \    
    && git clone -b android-4.4_r1.2 https://android.googlesource.com/platform/external/zlib \
    && git clone -b android-4.4_r1.2 https://android.googlesource.com/platform/external/openssl \
    && git clone -b android-4.4_r1.2 https://android.googlesource.com/platform/external/libselinux    
    
ADD core /tools/adb/system/core/    
   
RUN cd /tools/adb/system/core/adb && make   
RUN cd /tools/adb/system/core/fastboot && make
 
RUN chmod a+x /tools/adb/system/core/adb/adb 
RUN ln -s /adb/system/core/adb/adb /usr/bin/adb
 
RUN chmod a+x /tools/adb/system/core/fastboot/fastboot 
RUN ln -s /tools/adb/system/core/fastboot/fastboot /usr/bin/fastboot

RUN apt-get update && apt-get install -y --force-yes --no-install-recommends openjdk-7-jdk openjdk-7-jre

RUN apt-get update && apt-get install -y --force-yes --no-install-recommends unzip wget nano screen

# Ubuntu's Gradle package didn't deign to come with the "distribution" plugin...
RUN cd /tools && wget https://services.gradle.org/distributions/gradle-2.3-bin.zip && unzip gradle-2.3-bin.zip && rm *.zip
ENV GRADLE_HOME /tools/gradle-2.3

# Build JD-GUI: http://jd.benow.ca/
RUN cd /tools && git clone https://github.com/java-decompiler/jd-gui.git && cd jd-gui \
    && export PATH=$PATH:$GRADLE_HOME/bin && gradle build

# Build dex2jar: https://github.com/pxb1988/dex2jar    
RUN cd /tools && git clone https://github.com/pxb1988/dex2jar.git && cd dex2jar \
    && export PATH=$PATH:$GRADLE_HOME/bin && gradle build
        
# Install a funny little tool for grabbing .apk files from the Google PlayStore:
# http://codingteam.net/project/googleplaydownloader
# No, this isn't in Trusty back-ports... http://packages.ubuntu.com/search?keywords=python-ndg-httpsclient    
RUN cd /tools/ && wget http://cz.archive.ubuntu.com/ubuntu/pool/universe/n/ndg-httpsclient/python-ndg-httpsclient_0.3.2-1_all.deb
RUN apt-get update && apt-get install -y --force-yes --no-install-recommends subversion python-pip python-openssl python-support python-configparser python-protobuf python-pyasn1 python-requests python-wxgtk2.8
RUN cd /tools && dpkg -i python-ndg-httpsclient_0.3.2-1_all.deb
# The source seems to be more reliable than their grotty .deb... ...it can't generate the Android IDs. 
RUN cd /tools && svn checkout http://svn.codingteam.net/googleplaydownloader

ENV USERNAME ubuntu    
RUN export PASS=ubuntu && useradd --create-home --shell /bin/bash --user-group --groups adm,sudo $USERNAME \
    && echo "$USERNAME:$PASS" | chpasswd 
    
# Everything you never wanted to know about LXDE menus, and were too indifferent to ask:
# https://lkubaski.wordpress.com/2012/11/02/adding-lxde-start-menu-sections/
RUN mkdir -p /home/$USERNAME/.config/menus
ADD menus /home/$USERNAME/.config/menus 
RUN chown -R $USERNAME /home/$USERNAME/.config/

RUN mkdir -p /home/$USERNAME/.local/share/
ADD desktop-directories /home/$USERNAME/.local/share/desktop-directories/
ADD applications /home/$USERNAME/.local/share/applications/
RUN chown -R $USERNAME /home/$USERNAME/.local/
 
ADD noVNC /noVNC/
ADD startup.sh / 
ADD supervisord.conf /
EXPOSE 6080
EXPOSE 5900
EXPOSE 22
WORKDIR /
ENTRYPOINT ["/startup.sh"]
