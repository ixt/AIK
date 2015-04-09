
# Gratefully stolen from the 32-bit Ubuntu Docker repos:
# https://github.com/docker-32bit
# https://registry.hub.docker.com/repos/32bit/
FROM 32bit/ubuntu:14.04

# We also want a 32-bit Docker:
# http://mwhiteley.com/linux-containers/2013/08/31/docker-on-i386.html

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
        ca-certificates git build-essential libncurses5-dev libssl-dev
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Build adb from source because of the dodginess of distributing Google's binaries...    
#http://www.zdnet.com/article/no-google-is-not-making-the-android-sdk-proprietary-whats-the-fuss-about/    

# Build instructions and Makefiles gratefully stolen from here:
# http://android.serverbox.ch/?p=1217

RUN mkdir -p /root/adb/system
RUN cd /root/adb/system \
    && git clone -b android-4.4_r1.2 https://android.googlesource.com/platform/system/core \
    && git clone -b android-4.4_r1.2 https://android.googlesource.com/platform/system/extras

RUN mkdir -p /root/adb/external    
RUN cd /root/adb/external \    
    && git clone -b android-4.4_r1.2 https://android.googlesource.com/platform/external/zlib \
    && git clone -b android-4.4_r1.2 https://android.googlesource.com/platform/external/openssl \
    && git clone -b android-4.4_r1.2 https://android.googlesource.com/platform/external/libselinux    
    
ADD core /root/adb/system/core/    
   
RUN cd /root/adb/system/core/adb && make   
RUN cd /root/adb/system/core/fastboot && make

#RUN chmod -R a+rwx /home/ddk/adb/  
 
RUN chmod a+x /root/adb/system/core/adb/adb 
RUN mv /root/adb/system/core/adb/adb /usr/bin
 
RUN chmod a+x /root/adb/system/core/fastboot/fastboot 
RUN mv /root/adb/system/core/fastboot/fastboot /usr/fastboot
 
ADD noVNC /noVNC/
ADD startup.sh /
ADD supervisord.conf /
EXPOSE 6080
EXPOSE 5900
EXPOSE 22
WORKDIR /
ENTRYPOINT ["/startup.sh"]
