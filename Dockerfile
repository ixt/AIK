

FROM ubuntu:14.04.3


MAINTAINER Giles Greenway <giles.greenway@kcl.ac.uk>
# Also gratefully stolen from docker-ubuntu-vnc-desktop:
# https://github.com/fcwu/docker-ubuntu-vnc-desktop

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# no Upstart or DBus
# https://github.com/dotcloud/docker/issues/1724#issuecomment-26294856
RUN apt-mark hold initscripts udev plymouth mountall
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

RUN apt-get update && apt-get install -y --force-yes --no-install-recommends supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        qt4-qmake cmake libsqlite3-dev libqt4-dev libqt4-core libqt4-qt3support \
        ca-certificates git build-essential libncurses5-dev libssl-dev \
        nginx php5-common php5-cli \
        php5-fpm \
        python-pip \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Build adb from source because of the dodginess of distributing Google's binaries...    
#http://www.zdnet.com/article/no-google-is-not-making-the-android-sdk-proprietary-whats-the-fuss-about/    

# Build instructions and Makefiles gratefully stolen from here:
# http://android.serverbox.ch/?p=1217

RUN mkdir -p /tools/adb/system
WORKDIR /tools/
RUN cd /tools/adb/system \
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
RUN ln -s /tools/adb/system/core/adb/adb /usr/bin/adb
 
RUN chmod a+x /tools/adb/system/core/fastboot/fastboot 
RUN ln -s /tools/adb/system/core/fastboot/fastboot /usr/bin/fastboot

RUN apt-get update && apt-get install -y --force-yes --no-install-recommends openjdk-7-jdk openjdk-7-jre unzip wget nano screen gedit

# Ubuntu's Gradle package didn't deign to come with the "distribution" plugin...
RUN wget https://services.gradle.org/distributions/gradle-2.3-bin.zip && unzip gradle-2.3-bin.zip && rm *.zip
ENV GRADLE_HOME /tools/gradle-2.3

# Build JD-GUI: http://jd.benow.ca/
RUN git clone https://github.com/java-decompiler/jd-gui.git && cd jd-gui && export PATH=$PATH:$GRADLE_HOME/bin && gradle build
    
# Build dex2jar: https://github.com/pxb1988/dex2jar    
RUN git clone https://github.com/pxb1988/dex2jar.git && cd dex2jar && export PATH=$PATH:$GRADLE_HOME/bin && gradle build    
    
RUN tar -xf /tools/dex2jar/dex-tools/build/distributions/dex-tools-2.1-SNAPSHOT.tar -C /tools/dex2jar/
RUN chmod a+x /tools/dex2jar/dex-tools-2.1-SNAPSHOT/*.sh
ENV PATH $PATH:/tools/dex2jar/dex-tools-2.1-SNAPSHOT    
    
RUN wget http://www.onyxbits.de/sites/default/files/download/25/raccoon-3.7.jar

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y --force-yes libc6:i386 libncurses5:i386 libstdc++6:i386
RUN wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.2.1.jar
RUN mv apktool_2.2.1.jar apktool.jar
RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
RUN chmod a+x apktool

RUN wget https://bitbucket.org/JesusFreke/smali/downloads/smali-2.2b4.jar
RUN wget https://bitbucket.org/JesusFreke/smali/downloads/baksmali-2.2b4.jar
RUN mv smali-2.2b4.jar smali.jar && mv baksmali-2.2b4.jar baksmali.jar

# http://www.symantec.com/connect/blogs/monitoring-android-network-traffic-part-iv-forwarding-wireshark
RUN apt-get update && apt-get install -y --force-yes --no-install-recommends zenity wireshark tshark flex byacc \
    binutils-arm-linux-gnueabi gcc-arm-linux-gnueabi g++-arm-linux-gnueabi libc6-armel-cross libc6-dev-armel-cross
ENV CC arm-linux-gnueabi-gcc
RUN wget http://sourceforge.net/projects/netcat/files/netcat/0.7.1/netcat-0.7.1.tar.gz && tar -xvzf netcat-0.7.1.tar.gz
RUN cd /tools/netcat-0.7.1 && export LDFLAGS=-static && ./configure --host=arm-linux \
    && make && arm-linux-gnueabi-strip src/netcat    
# http://www.symantec.com/connect/blogs/monitoring-android-network-traffic-part-ii-cross-compiling-tcpdump    
RUN wget http://www.tcpdump.org/release/tcpdump-4.7.3.tar.gz && wget http://www.tcpdump.org/release/libpcap-1.7.2.tar.gz    
RUN tar -xvzf libpcap-1.7.2.tar.gz && cd libpcap-1.7.2 && ./configure --host=arm-linux --with-pcap=linux && make     
RUN tar zxvf tcpdump-4.7.3.tar.gz && cd tcpdump-4.7.3 && export ac_cv_linux_vers=3 && export CPPFLAGS=-static \
    && export LDFLAGS=-static && ./configure --host=arm-linux --disable-ipv6 && make && arm-linux-gnueabi-strip tcpdump    
RUN rm *.gz && mkdir -p /tools/droidscripts   
RUN mkdir -p /tools/droidbin && ln -s /tools/netcat-0.7.1/src/netcat /tools/droidbin/netcat \
    && cp /tools/tcpdump-4.7.3/tcpdump /tools/droidbin/tcpdump && chmod -R a+rx /tools/droidbin
ENV droidbin /tools/droidbin
ENV CC gcc

# https://github.com/google/vpn-reverse-tether
RUN git clone https://github.com/google/vpn-reverse-tether.git
RUN cd vpn-reverse-tether && make -C jni

RUN mkdir -p /tools/apk && chmod -R a+r /tools/apk
ADD apk /tools/apk

# Android-SSL-TrustKiller: https://github.com/iSECPartners/Android-SSL-TrustKiller
RUN cd /tools/apk && wget https://github.com/iSECPartners/Android-SSL-TrustKiller/releases/download/v1/Android-SSL-TrustKiller.apk

# AndroGuard http://code.google.com/p/androguard/wiki/Installation
RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends ipython python-dev mercurial python-setuptools g++ \
    libbz2-dev libmuparser-dev libsparsehash-dev python-ptrace python-pygments python-pydot graphviz \
    liblzma-dev libsnappy-dev python-twisted gawk
RUN git clone https://github.com/androguard/androguard
RUN wget http://downloads.sourceforge.net/project/pyfuzzy/pyfuzzy/pyfuzzy-0.1.0/pyfuzzy-0.1.0.tar.gz
RUN tar xvfz pyfuzzy-0.1.0.tar.gz
RUN cd pyfuzzy-0.1.0 && python setup.py install
RUN git clone git://github.com/ahupp/python-magic.git
RUN cd python-magic && python setup.py install

# https://github.com/sqlitebrowser/sqlitebrowser/releases/tag/v3.7.0
RUN wget https://github.com/sqlitebrowser/sqlitebrowser/archive/v3.7.0.tar.gz
RUN tar -xvf v3.7.0.tar.gz && cd sqlitebrowser-3.7.0 && qmake && make

# https://github.com/mwrlabs/drozer
RUN mkdir -p /tools/drozer
RUN cd /tools/drozer && wget https://github.com/mwrlabs/drozer/releases/download/2.3.4/drozer-2.3.4.tar.gz
RUN cd /tools/drozer && tar -xvzf drozer-2.3.4.tar.gz && easy_install drozer-2.3.4-py2.7.egg
RUN rm -rf /tools/drozer

# http://code.google.com/p/snappy/
# https://github.com/google/snappy
RUN wget "https://drive.google.com/uc?export=download&id=0B0xs9kK-b5nMOWIxWGJhMXd6aGs" -O snappy-1.1.2.tar.gz
RUN tar -xvzf snappy-1.1.2.tar.gz && rm snappy-1.1.2.tar.gz 
RUN cd snappy-1.1.2 && ./configure && make && make install

#RUN cd /tools/androguard/elsim && git clone https://github.com/google/snappy.git
#RUN cd /tools/androguard/elsim && wget http://sparsehash.googlecode.com/files/sparsehash-2.0.2.tar.gz \
#    && tar -xzf sparsehash-2.0.2.tar.gz && rm sparsehash-2.0.2.tar.gz 
#RUN cd /tools/androguard/elsim && svn checkout http://muparser.googlecode.com/svn/trunk/ muparser-read-only

#RUN mkdir mercury
#RUN wget http://labs.mwrinfosecurity.com/assets/254/mercury-v1.0.zip
#RUN wget https://www.mwrinfosecurity.com/system/assets/931/original/drozer_2.3.4.deb
#RUN dpkg -i drozer_2.3.4.deb
#RUN unzip mercury-v1.0.zip
#RUN cd androguard && ln -s ../mercury ./mercury

RUN cd androguard && python setup.py install

#RUN wget https://launchpad.net/gephi/0.8/0.8.2beta/+download/gephi-0.8.2-beta.tar.gz
#RUN tar -xzf gephi-0.8.2-beta.tar.gz && rm gephi-0.8.2-beta.tar.gz

# http://portswigger.net/burp/proxy.html
RUN wget https://portswigger.net/DownloadUpdate.ashx?Product=Free
RUN mv DownloadUpdate.ashx?Product=Free burpsuite_free.jar

ENV USERNAME ubuntu    
RUN export PASS=ubuntu && useradd --create-home --shell /bin/bash --user-group --groups adm,sudo $USERNAME \
    && echo "$USERNAME:$PASS" | chpasswd 
    
# http://elfinder.org/    
RUN mkdir -p /var/www/jquery
RUN cd /var/www/jquery/ && wget http://code.jquery.com/jquery-2.1.3.js
RUN cd /var/www && wget http://jqueryui.com/resources/download/jquery-ui-1.11.4.zip \
    && unzip jquery-ui-1.11.4.zip && rm *.zip
RUN mkdir -p /var/www/elfinder && cd /var/www/elfinder && wget http://nao-pon.github.io/elFinder-nightly/latests/elfinder-2.1.zip \
    && unzip elfinder-2.1.zip && rm *.zip
ADD nginx /etc/nginx/sites-available
ADD www /var/www 
RUN chmod -R 0755 /var/www     
RUN chmod -R a+rw /home/$USERNAME

# http://www.mkdocs.org/
RUN pip install mkdocs 
RUN mkdir -p /var/docs/ddkdocs && chmod -R a+r /var/docs/ddkdocs
ADD ddkdocs /var/docs/ddkdocs

ADD droidscripts /tools/droidscripts
RUN mkdir -p /home/$USERNAME/screenshots && chmod -R a+rwx /home/$USERNAME/screenshots

# Everything you never wanted to know about LXDE menus, and were too indifferent to ask:
# https://lkubaski.wordpress.com/2012/11/02/adding-lxde-start-menu-sections/
RUN mkdir -p /home/$USERNAME/.config/menus
ADD menus /home/$USERNAME/.config/menus 
RUN chown -R $USERNAME /home/$USERNAME/.config/

RUN mkdir -p /home/$USERNAME/.local/share/
ADD desktop-directories /home/$USERNAME/.local/share/desktop-directories/
ADD applications /home/$USERNAME/.local/share/applications/
RUN chown -R $USERNAME /home/$USERNAME/.local/

RUN mkdir -p /home/$USERNAME/Raccoon/archives/default/apk_storage/
RUN chown -R $USERNAME /home/$USERNAME/Raccoon
RUN chmod -R a+rw /home/$USERNAME/Raccoon
RUN ln -s /home/$USERNAME/Raccoon/archives/default/apk_storage/ /home/$USERNAME
RUN mkdir -p /home/$USERNAME/jarfiles
RUN chown -R $USERNAME /home/$USERNAME/jarfiles
RUN chmod -R a+rw /home/$USERNAME/jarfiles

ADD noVNC /noVNC/
ADD startup.sh / 
ADD supervisord.conf /

EXPOSE 6080
EXPOSE 5900
EXPOSE 80
EXPOSE 8082
EXPOSE 22
WORKDIR /
ENTRYPOINT ["/startup.sh"]
