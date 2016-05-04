#!/usr/local/bin/dumb-init /bin/bash
source /etc/bashrc
source /opt/qnib/consul/etc/bash_functions.sh

if [ "X${HBASE_MASTER}" != "Xtrue" ];then
   echo ">> Do not start master"
   rm -f /etc/consul.d/hbase-master.json
   consul reload
fi

mkdir -p /opt/hbase/logs/
chown -R hadoop /opt/hbase/logs/

wait_for_srv zookeeper
wait_for_srv hbase-regionserver
sleep 2

consul-template -consul localhost:8500 -once -template "/etc/consul-templates/hbase/hbase-site.xml.ctmpl:/opt/hbase/conf/hbase-site.xml"
echo "starting hbase"
su -c "/opt/hbase/bin/hbase --config /opt/hbase/conf/ master start" hadoop
