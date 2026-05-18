#!/bin/sh

REALM="EXAMPLE.COM"
KEYTAB_DIR="/etc/security/keytab"
KDC_DIR="/var/lib/krb5kdc"
ENCTYPE="aes128-cts-hmac-sha1-96:normal"
# Docker Compose default network name (project_dir_default)
NET_SUFFIX="hadoop_default"

echo "=== Starting KDC server ==="
# Start the original entrypoint in the background (it execs supervisord)
/docker-entrypoint.sh &
KDC_PID=$!

# Wait for KDC database to be created by the original entrypoint
echo "=== Waiting for KDC database ==="
max_wait=30
waited=0
while [ ! -f "${KDC_DIR}/principal" ]; do
    if [ $waited -ge $max_wait ]; then
        echo "ERROR: KDC database not found after ${max_wait}s"
        exit 1
    fi
    echo "Waiting for KDC database... (${waited}s)"
    sleep 1
    waited=$((waited + 1))
done

# Wait a bit more for KDC to be fully ready
sleep 2

echo "=== KDC database ready, fixing krbtgt to AES-128 only (Java 8 compat) ==="

# Fix krbtgt principal to only use AES-128 (Java 8u131 doesn't support AES-256 without JCE)
kadmin.local -q "change_password -randkey -e ${ENCTYPE} krbtgt/${REALM}@${REALM}"

echo "=== Creating service principals and keytabs (AES-128 only) ==="

# NameNode principal - create both short and FQDN (Docker resolves FQDN via reverse DNS)
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} nn/namenode@${REALM}" 2>/dev/null || echo "nn/namenode principal already exists"
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} nn/namenode.${NET_SUFFIX}@${REALM}" 2>/dev/null || echo "nn/namenode.${NET_SUFFIX} principal already exists"
kadmin.local -q "xst -k ${KEYTAB_DIR}/nn.service.keytab -e ${ENCTYPE} nn/namenode@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/nn.service.keytab -e ${ENCTYPE} nn/namenode.${NET_SUFFIX}@${REALM}"

# DataNode principal - create both short and FQDN
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} dn/datanode@${REALM}" 2>/dev/null || echo "dn/datanode principal already exists"
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} dn/datanode.${NET_SUFFIX}@${REALM}" 2>/dev/null || echo "dn/datanode.${NET_SUFFIX} principal already exists"
kadmin.local -q "xst -k ${KEYTAB_DIR}/dn.service.keytab -e ${ENCTYPE} dn/datanode@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/dn.service.keytab -e ${ENCTYPE} dn/datanode.${NET_SUFFIX}@${REALM}"

# ResourceManager principal - create both short and FQDN
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} rm/resourcemanager@${REALM}" 2>/dev/null || echo "rm/resourcemanager principal already exists"
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} rm/resourcemanager.${NET_SUFFIX}@${REALM}" 2>/dev/null || echo "rm/resourcemanager.${NET_SUFFIX} principal already exists"
kadmin.local -q "xst -k ${KEYTAB_DIR}/rm.service.keytab -e ${ENCTYPE} rm/resourcemanager@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/rm.service.keytab -e ${ENCTYPE} rm/resourcemanager.${NET_SUFFIX}@${REALM}"

# NodeManager principal - create both short and FQDN
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} nm/nodemanager@${REALM}" 2>/dev/null || echo "nm/nodemanager principal already exists"
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} nm/nodemanager.${NET_SUFFIX}@${REALM}" 2>/dev/null || echo "nm/nodemanager.${NET_SUFFIX} principal already exists"
kadmin.local -q "xst -k ${KEYTAB_DIR}/nm.service.keytab -e ${ENCTYPE} nm/nodemanager@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/nm.service.keytab -e ${ENCTYPE} nm/nodemanager.${NET_SUFFIX}@${REALM}"

# Hive Metastore principal - create both short and FQDN
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} hive/hive-metastore@${REALM}" 2>/dev/null || echo "hive/hive-metastore principal already exists"
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} hive/hive-metastore.${NET_SUFFIX}@${REALM}" 2>/dev/null || echo "hive/hive-metastore.${NET_SUFFIX} principal already exists"
kadmin.local -q "xst -k ${KEYTAB_DIR}/hive-metastore.service.keytab -e ${ENCTYPE} hive/hive-metastore@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/hive-metastore.service.keytab -e ${ENCTYPE} hive/hive-metastore.${NET_SUFFIX}@${REALM}"

# Hive Server2 principal - create both short and FQDN
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} hive/hive-server@${REALM}" 2>/dev/null || echo "hive/hive-server principal already exists"
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} hive/hive-server.${NET_SUFFIX}@${REALM}" 2>/dev/null || echo "hive/hive-server.${NET_SUFFIX} principal already exists"
kadmin.local -q "xst -k ${KEYTAB_DIR}/hive-server.service.keytab -e ${ENCTYPE} hive/hive-server@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/hive-server.service.keytab -e ${ENCTYPE} hive/hive-server.${NET_SUFFIX}@${REALM}"

# HTTP/SPNEGO principals for web UI authentication - create both short and FQDN
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} HTTP/namenode@${REALM}" 2>/dev/null || echo "HTTP/namenode principal already exists"
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} HTTP/namenode.${NET_SUFFIX}@${REALM}" 2>/dev/null || echo "HTTP/namenode.${NET_SUFFIX} principal already exists"
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} HTTP/datanode@${REALM}" 2>/dev/null || echo "HTTP/datanode principal already exists"
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} HTTP/datanode.${NET_SUFFIX}@${REALM}" 2>/dev/null || echo "HTTP/datanode.${NET_SUFFIX} principal already exists"
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} HTTP/resourcemanager@${REALM}" 2>/dev/null || echo "HTTP/resourcemanager principal already exists"
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} HTTP/resourcemanager.${NET_SUFFIX}@${REALM}" 2>/dev/null || echo "HTTP/resourcemanager.${NET_SUFFIX} principal already exists"
kadmin.local -q "xst -k ${KEYTAB_DIR}/spnego.service.keytab -e ${ENCTYPE} HTTP/namenode@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/spnego.service.keytab -e ${ENCTYPE} HTTP/namenode.${NET_SUFFIX}@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/spnego.service.keytab -e ${ENCTYPE} HTTP/datanode@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/spnego.service.keytab -e ${ENCTYPE} HTTP/datanode.${NET_SUFFIX}@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/spnego.service.keytab -e ${ENCTYPE} HTTP/resourcemanager@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/spnego.service.keytab -e ${ENCTYPE} HTTP/resourcemanager.${NET_SUFFIX}@${REALM}"

# Create a combined hive keytab for services that reference hive.service.keytab
kadmin.local -q "xst -k ${KEYTAB_DIR}/hive.service.keytab -e ${ENCTYPE} hive/hive-metastore@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/hive.service.keytab -e ${ENCTYPE} hive/hive-metastore.${NET_SUFFIX}@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/hive.service.keytab -e ${ENCTYPE} hive/hive-server@${REALM}"
kadmin.local -q "xst -k ${KEYTAB_DIR}/hive.service.keytab -e ${ENCTYPE} hive/hive-server.${NET_SUFFIX}@${REALM}"


# 生成一个客户端用的keytab
kadmin.local -q "addprinc -randkey -e ${ENCTYPE} client/client@${REALM}" 2>/dev/null || echo "client/client@${REALM} principal already exists"
kadmin.local -q "xst -k ${KEYTAB_DIR}/client.keytab -e ${ENCTYPE} client/client@${REALM}"

# Set permissions
chmod -R 755 ${KEYTAB_DIR}

echo "=== Keytabs generated successfully ==="
ls -la ${KEYTAB_DIR}/

echo "KDC is ready!"

# Keep container running by waiting for the background supervisord process
wait $KDC_PID
