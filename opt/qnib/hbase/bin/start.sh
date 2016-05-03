#!/usr/local/bin/dumb-init /bin/bash
source /etc/bashrc
source /opt/qnib/consul/etc/bash_functions.sh

mkdir -p /opt/hbase/logs/
chown -R hadoop /opt/hbase/logs/
echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

wait_for_srv hdfs-datanode
sleep 5
echo "starting hbase"
/opt/hbase/bin/hbase-daemon.sh foreground_start master 
