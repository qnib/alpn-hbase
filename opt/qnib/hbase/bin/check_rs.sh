#!/bin/bash

IP_ADD=$(ip -o -4 address |grep eth0 |egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+")
echo "> nmap ${IP_ADD} -p $1 |grep open"
nmap ${IP_ADD} -p $1 |grep open
exit $?
