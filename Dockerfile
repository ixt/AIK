FROM alpine

ENV DEBIAN_FRONTEND=noninteractive \
        LANG=en_US.UTF-8 \
        LANGUAGE=en_US.UTF-8 \
        LC_ALL=C.UTF-8 \
        DISPLAY=:0.0 

RUN echo http://dl-3.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN echo http://dl-3.alpinelinux.org/alpine/v3.6/main >> /etc/apk/repositories
RUN echo http://alpine.reveb.la/builder >> /etc/apk/repositories

RUN apk --update --upgrade --allow-untrusted add ca-certificates bash net-tools python git x11vnc openrc procps xvfb xfce4 socat supervisor novnc websockify sqlitebrowser

RUN apk add wget unzip openjdk8 android-tools paxctl
RUN apk add g++ make

# Adjust privilege protections for java
RUN paxctl -c /usr/lib/jvm/java-1.8-openjdk/bin/java
RUN paxctl -m /usr/lib/jvm/java-1.8-openjdk/bin/java

RUN mkdir -p /tools
ENV PATH $PATH:/tools/
WORKDIR /tools

RUN wget https://github.com/java-decompiler/jd-gui/releases/download/v1.4.0/jd-gui-1.4.0.jar 

RUN wget https://github.com/pxb1988/dex2jar/releases/download/2.0/dex-tools-2.0.zip
RUN unzip dex-tools-2.0.zip
RUN rm *.zip
RUN chmod a+x /tools/dex2jar-2.0/*.sh
ENV PATH $PATH:/tools/dex2jar-2.0/

RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
RUN chmod a+x apktool
RUN wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.3.0.jar
RUN mv apktool_2.3.0.jar apktool.jar

RUN wget https://bitbucket.org/JesusFreke/smali/downloads/smali-2.2b4.jar
RUN wget https://bitbucket.org/JesusFreke/smali/downloads/baksmali-2.2b4.jar
RUN mv smali-2.2b4.jar smali.jar && mv baksmali-2.2b4.jar baksmali.jar

RUN mkdir -p /tools/droidbin
WORKDIR /tools/droidbin
RUN wget https://github.com/jakev/android-binaries/raw/master/nc && mv nc netcat
RUN wget https://www.androidtcpdump.com/download/4.9.2/tcpdump

RUN mkdir -p /tools/apk
WORKDIR /tools/apk
RUN wget https://github.com/iSECPartners/Android-SSL-TrustKiller/releases/download/v1/Android-SSL-TrustKiller.apk
RUN wget https://github.com/mwrlabs/drozer/releases/download/2.3.4/drozer-agent-2.3.4.apk

RUN apk add wireshark zenity tshark
WORKDIR /tools/

RUN apk add py-setuptools py-pip python-dev openssl-dev libffi-dev
RUN pip install twisted service_identity
RUN git clone https://github.com/mwrlabs/drozer drozer
WORKDIR /tools/drozer
RUN PATH=$PATH:/usr/lib/jvm/java-1.8-openjdk/bin && python setup.py build && python setup.py install
WORKDIR /tools/

RUN wget https://portswigger.net/DownloadUpdate.ashx?Product=Free
RUN mv DownloadUpdate.ashx?Product=Free burpsuite_free.jar

RUN wget https://github.com/skylot/jadx/releases/download/v0.6.0/jadx-0.6.0.zip
RUN unzip jadx-0.6.0.zip && rm jadx-0.6.0.zip 

RUN wget http://raccoon.onyxbits.de/sites/raccoon.onyxbits.de/files/raccoon-4.2.5.jar

RUN apk add python3 
RUN pip3 install browsepy mkdocs

RUN apk add leafpad gpicview grep xarchiver coreutils xfce4-screenshooter

ENV HOMEDIR /root
ENV DROIDBIN /tools/droidbin
RUN mkdir -p $HOMEDIR/screenshots

ADD droidscripts /tools/droidscripts

RUN mkdir -p /root/.config/menus
ADD xfce4_menu /root/.config/menus
ADD xfce4 /root/.config/xfce4

ADD applications /usr/share/applications

WORKDIR /root
RUN mkdir -p Raccoon/content/apps
RUN ln -s Raccoon/content/apps

ADD ddkdocs /ddkdocs
WORKDIR /ddkdocs
RUN mkdocs build

WORKDIR /root

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
