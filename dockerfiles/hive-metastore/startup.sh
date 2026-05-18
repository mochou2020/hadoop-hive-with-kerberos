#!/bin/bash

# Kerberos login if HADOOP_CLIENT_KEYTAB and HADOOP_CLIENT_PRINCIPAL are set
if [ -n "$HADOOP_CLIENT_KEYTAB" ] && [ -n "$HADOOP_CLIENT_PRINCIPAL" ]; then
    echo "Logging in with Kerberos: $HADOOP_CLIENT_PRINCIPAL"
    kinit -k -t "$HADOOP_CLIENT_KEYTAB" "$HADOOP_CLIENT_PRINCIPAL" || echo "WARNING: kinit failed"
fi

/opt/hive/bin/hive --service metastore
