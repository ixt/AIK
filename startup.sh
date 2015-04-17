#!/bin/bash

mkdir -p /var/run/sshd

# create an ubuntu user
# PASS=`pwgen -c -n -1 10`
#PASS=ubuntu
# echo "Username: ubuntu Password: $PASS"
#id -u ubuntu &>/dev/null || useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu
#echo "ubuntu:$PASS" | chpasswd

cd /var/docs/ddkdocs
mkdocs build
mkdir -p /var/www/docs
cp -r /var/docs/ddkdocs/site/* /var/www/docs

/usr/bin/supervisord -c /supervisord.conf

/bin/bash