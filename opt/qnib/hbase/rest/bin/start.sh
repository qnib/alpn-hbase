#!/usr/local/bin/dumb-init /bin/bash
source /etc/bashrc
source /opt/qnib/consul/etc/bash_functions.sh

if [ "X${HBASE_REST}" != "Xtrue" ];then
   echo ">> Do not start rest"
   rm -f /etc/consul.d/hbase-rest*.json
   consul reload
   sleep 2
   exit 0
fi

wait_for_srv hbase-master
sleep 2

echo "starting hbase-rest"
su -c "/opt/hbase/bin/hbase --config /opt/hbase/conf/ rest start -p 16070 --infoport 16080" hadoop
