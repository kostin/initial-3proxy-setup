#!/bin/bash

DLPATH='https://github.com/kostin/initial-3proxy-setup/raw/master'

if grep -q 'CentOS release 6' /etc/redhat-release; then
	clear
	echo 'Starting install 3proxy on '`hostname`
	echo 'Press Enter to continue (Ctrl+C to exit)!'
	read
else
	echo 'Wrong OS!';
	exit 0;
fi

USER=`hostname -s`
#IP=`ip addr show eth0 | grep 'inet ' | awk '{print $2}' | awk -F/ '{print $1}'`

if [ -a /root/.3proxy-password ]; then 
	PASSWORD=`cat /root/.3proxy-password`	
	echo "Already set up with password $PASSWORD"
else
	yum -y install epel-release
	sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo
	yum -y update
	yum -y install pwgen curl 3proxy
	yum -y clean all
	PASSWORD=`pwgen 16 1`
	IP=`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`
	echo $PASSWORD > /root/.3proxy-password
	chmod 400 /root/.3proxy-password
	cp /etc/3proxy.cfg /etc/3proxy.cfg.dist
	cd /etc
	wget -N $DLPATH/3proxy.cfg
	sed -i "s/mytestuser/$USER/g" /etc/3proxy.cfg
	sed -i "s/mytestpassword/$PASSWORD/g" /etc/3proxy.cfg
	echo "3proxy user: $USER"
	echo "3proxy password: $PASSWORD"
	echo "3proxy IP: $IP"
	echo "3proxy HTTP/HTTPS default port: 3128"
	service 3proxy start
	chkconfig 3proxy on
fi
