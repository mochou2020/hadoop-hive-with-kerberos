#!/bin/bash

# Kerberos login if HADOOP_CLIENT_KEYTAB and HADOOP_CLIENT_PRINCIPAL are set
if [ -n "$HADOOP_CLIENT_KEYTAB" ] && [ -n "$HADOOP_CLIENT_PRINCIPAL" ]; then
    echo "Logging in with Kerberos: $HADOOP_CLIENT_PRINCIPAL"
    kinit -k -t "$HADOOP_CLIENT_KEYTAB" "$HADOOP_CLIENT_PRINCIPAL" || echo "WARNING: kinit failed"
fi

hadoop fs -mkdir       /tmp
hadoop fs -mkdir -p    /user/hive/warehouse
hadoop fs -chmod g+w   /tmp
hadoop fs -chmod g+w   /user/hive/warehouse

cd $HIVE_HOME/bin
./hiveserver2 --hiveconf hive.server2.enable.doAs=false
