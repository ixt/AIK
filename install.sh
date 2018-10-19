#!/bin/bash
# export DEBIAN_FRONTEND=noninteractive \
#         LANG=en_US.UTF-8 \
#         LANGUAGE=en_US.UTF-8 \
#         LC_ALL=C.UTF-8 \
#         DISPLAY=:0.0 

# orange@reveb.la-5b97ad9b.rsa.pub /etc/apk/keys/orange@reveb.la-5b97ad9b.rsa.pub

sudo apt install -s ca-certificates bash net-tools python git x11vnc openrc \
    procps xvfb xfce4 socat supervisor novnc websockify sqlitebrowser wget \
    unzip openjdk-8-jre openjdk-8-jdk android-tools-adb android-tools-fastboot \
    paxctl g++ make python3 wireshark zenity tshark python-setuptools \
    python-pip python-dev libssl-dev libffi-dev leafpad gpicview grep xarchiver \
    coreutils xfce4-screenshooter
exit 0

# Adjust privilege protections for java
paxctl -c /usr/lib/jvm/java-1.8-openjdk/bin/java
paxctl -m /usr/lib/jvm/java-1.8-openjdk/bin/java

mkdir -p /opt/tools
export PATH="$PATH:/opt/tools/"

cd /tools
wget https://github.com/java-decompiler/jd-gui/releases/download/v1.4.0/jd-gui-1.4.0.jar 

wget https://github.com/pxb1988/dex2jar/releases/download/2.0/dex-tools-2.0.zip
unzip dex-tools-2.0.zip
rm *.zip
chmod a+x /opt/tools/dex2jar-2.0/*.sh
export PATH="$PATH:/opt/tools/dex2jar-2.0/"

wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
chmod a+x apktool
wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.3.0.jar
mv apktool_2.3.0.jar apktool.jar

wget https://bitbucket.org/JesusFreke/smali/downloads/smali-2.2b4.jar
wget https://bitbucket.org/JesusFreke/smali/downloads/baksmali-2.2b4.jar
mv smali-2.2b4.jar smali.jar && mv baksmali-2.2b4.jar baksmali.jar

mkdir -p /opt/tools/droidbin
cd /opt/tools/droidbin
wget https://github.com/jakev/android-binaries/raw/master/nc && mv nc netcat
wget https://www.androidtcpdump.com/download/4.9.2/tcpdump

mkdir -p /opt/tools/apk
cd /opt/tools/apk
wget https://github.com/iSECPartners/Android-SSL-TrustKiller/releases/download/v1/Android-SSL-TrustKiller.apk
wget https://github.com/mwrlabs/drozer/releases/download/2.3.4/drozer-agent-2.3.4.apk

pip install twisted service_identity drozer

cd /opt/tools/
wget https://portswigger.net/DownloadUpdate.ashx?Product=Free -O burpsuite_free.jar

wget https://github.com/skylot/jadx/releases/download/v0.6.0/jadx-0.6.0.zip
unzip jadx-0.6.0.zip && rm jadx-0.6.0.zip 

wget http://raccoon.onyxbits.de/sites/raccoon.onyxbits.de/files/raccoon-4.2.6.jar

pip3 install browsepy mkdocs


export HOMEDIR="/root"
export DROIDBIN="/tools/droidbin"
mkdir -p $HOMEDIR/screenshots


mkdir -p $HOMEDIR/.config/menus
cp -r droidscripts /opt/tools/droidscripts
cp -r xfce4_menu $HOMEDIR/.config/menus
cp -r xfce4 $HOMEDIR/.config/xfce4

cp -r applications /usr/share/applications

cd $HOMEDIR
mkdir -p Raccoon/content/apps
ln -s Raccoon/content/apps

cp -r ddkdocs $HOMEDIR/ddkdocs
cd $HOMEDIR/ddkdocs
mkdocs build

cd $HOMEDIR

cp supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
