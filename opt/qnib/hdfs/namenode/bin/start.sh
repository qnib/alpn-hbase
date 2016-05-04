#!/usr/local/bin/dumb-init /bin/bash

source /etc/bashrc.hadoop
source /opt/qnib/consul/etc/bash_functions.sh

if [ "${HADOOP_HDFS_NAMENODE}" != "true" ];then
    echo "> 'HADOOP_HDFS_NAMENODE!=true' Remove service"
    rm -f /etc/consul.d/hdfs-namenode.json
    consul reload
    sleep 2
    exit 0
fi

wait_for_lock /tmp/hdfs_configure.done

if [ ! -d /data/hadoopdata/hdfs ];then
    mkdir -p /data/hadoopdata/hdfs
fi

chown -R hadoop: /data/hadoopdata/hdfs

if [ ! -d /data/hadoopdata/hdfs/namenode ];then
    echo "Formating namenode"
    su -c '/opt/hadoop/bin/hdfs --config /opt/hadoop/etc/hadoop/ namenode -format -force' hadoop
fi
if [ ! -d /data/hadoopdata/logs ];then
    mkdir /data/hadoopdata/logs/
    chown -R hadoop: /data/hadoopdata/logs/
    ln -s /data/hadoopdata/logs /opt/hadoop/
else
    chown -R hadoop: /opt/hadoop/logs
fi

# Wait for sshd to be up'n'running
#wait_for_srv ssh

sleep 3

HADOOP_HDFS_NAMENODE_URI=${HADOOP_HDFS_NAMENODE_URI-0.0.0.0}

su -c '/opt/hadoop/bin/hdfs --config /opt/hadoop/etc/hadoop/ namenode' hadoop
