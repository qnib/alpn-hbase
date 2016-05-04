FROM qnib/alpn-hdfs

ENV HBASE_VER=1.2.1 \
    HBASE_CLUSTER_DISTRIBUTED=true \
    HBASE_MASTER=false \
    HBASE_REGIONSERVER=false
RUN curl -fLs http://apache.org/dist/hbase/${HBASE_VER}/hbase-${HBASE_VER}-bin.tar.gz | tar xzf - -C /opt && mv /opt/hbase-${HBASE_VER} /opt/hbase
ADD etc/consul-templates/hbase/hbase-site.xml.ctmpl /etc/consul-templates/hbase/
ADD etc/supervisord.d/hbase-master.ini \
    etc/supervisord.d/hbase-regionserver.ini \
    /etc/supervisord.d/ 
ADD opt/qnib/hbase/master/bin/start.sh \
    opt/qnib/hbase/master/bin/check.sh \
    opt/qnib/hbase/master/bin/check_info.sh \
    /opt/qnib/hbase/master/bin/
ADD opt/qnib/hbase/bin/check.sh \
    opt/qnib/hbase/bin/check_rs.sh \
    /opt/qnib/hbase/bin/
ADD opt/qnib/hbase/regionserver/bin/start.sh /opt/qnib/hbase/regionserver/bin/
ADD etc/consul.d/hbase-master-info.json \
    etc/consul.d/hbase-master.json \
    etc/consul.d/hbase-regionserver-info.json \
    etc/consul.d/hbase-regionserver.json \
    /etc/consul.d/
ADD etc/bashrc.hbase /etc/bashrc.hbase
RUN echo "source /etc/bashrc.hbase" >> /etc/bashrc && \
    echo "tail -f /var/log/supervisor/hbase.log" >> /root/.bash_history
ENV HBASE_MANAGES_ZK=false
