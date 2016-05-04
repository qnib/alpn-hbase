#!/usr/local/bin/dumb-init /bin/bash

source /etc/bashrc.hadoop
source /opt/qnib/consul/etc/bash_functions.sh

if [ "${HADOOP_HDFS_DATANODE}" != "true" ];then
    echo "> 'HADOOP_HDFS_DATANODE!=true' Remove service"
    rm -f /etc/consul.d/hdfs-datanode.json
    consul reload
    sleep 2
    exit 0
fi

if [ ! -d /data/hadoopdata/logs ];then
    mkdir /data/hadoopdata/logs/
    chown -R hadoop: /data/hadoopdata/logs/
    ln -s /data/hadoopdata/logs /opt/hadoop/
else
    chown -R hadoop: /opt/hadoop/logs
fi

if [ ! -d /data/hadoopdata/hdfs/datanode ];then
    mkdir -p /data/hadoopdata/hdfs/datanode
    chown -R hadoop: /data/hadoopdata/hdfs/datanode
else
    chown -R hadoop: /data/hadoopdata/hdfs/datanode
fi

echo -n ">> Waiting for 'hdfs-namenode'.... "
wait_for_srv hdfs-namenode
sleep 2

su -c "/opt/hadoop/bin/hdfs --config /opt/hadoop/etc/hadoop/ datanode -fs hdfs://$(hostname).node.consul/" hadoop
