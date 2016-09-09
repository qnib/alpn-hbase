FROM qnib/alpn-hdfs

ARG HBASE_VER=1.2.2
ENV HBASE_CLUSTER_DISTRIBUTED=true \
    HBASE_MASTER=false \
    HBASE_MANAGES_ZK=false \
    HBASE_REGIONSERVER=false \
    HBASE_REST=false
RUN curl -fLs http://apache.org/dist/hbase/${HBASE_VER}/hbase-${HBASE_VER}-bin.tar.gz | tar xzf - -C /opt && mv /opt/hbase-${HBASE_VER} /opt/hbase
ADD etc/consul-templates/hbase/hbase-site.xml.ctmpl \
    etc/consul-templates/hbase/regionservers.ctmpl \
    /etc/consul-templates/hbase/
ADD etc/supervisord.d/hbase-master.ini \
    etc/supervisord.d/hbase-regionserver.ini \
    etc/supervisord.d/hbase-rest.ini \
    /etc/supervisord.d/
ADD opt/qnib/hbase/master/bin/start.sh \
    opt/qnib/hbase/master/bin/check.sh \
    opt/qnib/hbase/master/bin/check_info.sh \
    opt/qnib/hbase/master/bin/healthcheck.sh \
    /opt/qnib/hbase/master/bin/
ADD opt/qnib/hbase/rest/bin/start.sh \
    opt/qnib/hbase/rest/bin/check.sh \
    opt/qnib/hbase/rest/bin/healthcheck.sh \
    /opt/qnib/hbase/rest/bin/
ADD opt/qnib/hbase/bin/check.sh \
    opt/qnib/hbase/bin/check_rs.sh \
    /opt/qnib/hbase/bin/
ADD opt/qnib/hbase/regionserver/bin/start.sh \
    opt/qnib/hbase/regionserver/bin/healthcheck.sh \
    /opt/qnib/hbase/regionserver/bin/
ADD etc/consul.d/hbase-master-info.json \
    etc/consul.d/hbase-master.json \
    etc/consul.d/hbase-regionserver-info.json \
    etc/consul.d/hbase-regionserver.json \
    etc/consul.d/hbase-rest.json \
    /etc/consul.d/
ADD etc/bashrc.hbase /etc/bashrc.hbase
RUN echo "source /etc/bashrc.hbase" >> /etc/bashrc \
 && echo "/opt/hbase/bin/hbase org.apache.hadoop.hbase.PerformanceEvaluation sequentialWrite 100" >> /root/.bash_history \
 && echo "tail -f /var/log/supervisor/hbase-regionserver.log" >> /root/.bash_history \
 && echo "tail -f /var/log/supervisor/hbase-master.log" >> /root/.bash_history
