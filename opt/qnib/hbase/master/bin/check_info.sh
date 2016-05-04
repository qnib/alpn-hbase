#!/bin/bash

IP_ADD=$(ip -o -4 address |grep eth0 |egrep -o "\d+\.\d+\.\d+\.\d+")
echo "> curl -sI ${IP_ADD}:$1/master-status | grep 200"
curl -sI ${IP_ADD}:$1/master-status | grep 200
exit $?
