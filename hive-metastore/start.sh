#!/bin/bash
set -x  # 启用详细日志
echo "=== 开始 Hive Metastore 启动 ==="

# 检查必要命令
echo "检查命令..."
which nc
which schematool
which hive

# 等待 PostgreSQL
echo "等待 PostgreSQL..."
counter=0
while ! nc -z hive-metastore-postgresql 5432; do
  sleep 2
  counter=$((counter+1))
  if [ $counter -gt 30 ]; then
    echo "PostgreSQL 连接超时"
    exit 1
  fi
done
echo "PostgreSQL 已就绪"

# 初始化 Schema
echo "初始化 Schema..."
/opt/hive/bin/schematool -dbType postgres -initSchema

# 启动服务
echo "启动 Hive Metastore..."
exec /opt/hive/bin/hive --service metastore