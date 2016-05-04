#!/bin/bash

IP_ADD=$(ip -o -4 address |grep eth0 |egrep -o "\d+\.\d+\.\d+\.\d+")
echo "> nmap ${IP_ADD} -p $1 |grep open"
nmap ${IP_ADD} -p $1 |grep open
exit $?
