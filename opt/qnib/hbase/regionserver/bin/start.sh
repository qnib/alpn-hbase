#!/usr/local/bin/dumb-init /bin/bash
source /etc/bashrc
source /opt/qnib/consul/etc/bash_functions.sh
wait_for_srv consul-http

if [ "X${HBASE_REGIONSERVER}" != "Xtrue" ];then
   echo ">> Do not start regionserver"
   rm -f /etc/consul.d/hbase-regionserver*.json
   consul reload
   exit 0
fi

mkdir -p /opt/hbase/logs/
chown -R hadoop /opt/hbase/logs/

wait_for_srv hdfs-datanode
wait_for_srv hdfs-namenode

sleep 2

consul-template -consul localhost:8500 -once -template "/etc/consul-templates/hbase/hbase-site.xml.ctmpl:/opt/hbase/conf/hbase-site.xml"
consul-template -consul localhost:8500 -once -template "/etc/consul-templates/hbase/regionservers.ctmpl:/opt/hbase/conf/regionservers"

echo ">>> starting hbase regionserver"
su -c "/opt/hbase/bin/hbase --config /opt/hbase/conf/ regionserver start" hadoop
