#!/usr/local/bin/dumb-init /bin/bash

/opt/qnib/hbase/bin/check_rs.sh 16000
/opt/qnib/hbase/master/bin/check_info.sh 16010
