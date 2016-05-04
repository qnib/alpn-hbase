#!/bin/bash

# collection of function that help with scripting
function wait_for_node {
    if [ "X${START_TIME}" == "X" ];then
        START_TIME=$(date +%s)
    fi
    TIMEOUT=${2-999}
    if [ $(echo "$(date +%s)-${START_TIME}" |bc) -gt ${TIMEOUT} ];then
        echo "Timeout reached: ${TIMEOUT}"
        exit 1
    fi
    nmap 127.0.0.1 -p 8500|grep open >/dev/null
    if [ $? -ne 0 ];then
        echo -n "1"
        sleep 1
        wait_for_node ${1} ${TIMEOUT}
    fi
    curl -s localhost:8500/v1/catalog/node/${1}|jq . 1>/dev/null 2>/dev/null
    if [ $? -ne 0 ];then
        echo -n "2"
        sleep 1
        wait_for_node ${1} ${TIMEOUT}
    fi
}

function wait_for_srv {
    echo "Wait for service '$1' to be PASSING in consul. "
    echo -n "Waiting for (1: consul / 2: consul API / 3: service / 4: status=passing): "
    wait_for_srv_loop $@
}
function wait_for_srv_loop {
    if [ "X${START_TIME}" == "X" ];then
        START_TIME=$(date +%s)
    fi
    TIMEOUT=${2-999}
    if [ $(echo "$(date +%s)-${START_TIME}" |bc) -gt ${TIMEOUT} ];then
        echo "[FAIL] Timeout reached: ${TIMEOUT}"
        exit 1
    fi
    nmap 127.0.0.1 -p 8500|grep open >/dev/null
    if [ $? -ne 0 ];then
        echo -n "1"
        sleep 1
        wait_for_srv_loop ${1} ${TIMEOUT}
    fi
    curl -s localhost:8500/v1/catalog/services|jq . 1>/dev/null 2>/dev/null
    if [ $? -ne 0 ];then
        echo -n "2"
        sleep 1
        wait_for_srv_loop ${1} ${TIMEOUT}
    fi
    if [ $(curl -s localhost:8500/v1/catalog/service/${1} |jq ". | length") -eq 0 ];then
        echo -n "3"
        sleep 1
        wait_for_srv_loop ${1} ${TIMEOUT}
    fi
    if [ $(curl -s "localhost:8500/v1/health/checks/${1}?near=_agent" |jq ".[].Status" |tr -d '"') != "passing" ];then
        echo -n "4"
        sleep 1
        wait_for_srv_loop ${1} ${TIMEOUT}
    else
        echo " [OK]"
    fi
}

# Wait for a lock file to be created
function wait_for_lock {
    if [ ! -z $2 ];then
        echo "Waiting for '$2' to create '$1': "
    else
        echo -n "Wait for file to created '$1': "
    fi
    while [ ! -f $1 ];do
        echo -n "."
        sleep 1
    done
    echo " [OK]"
}
