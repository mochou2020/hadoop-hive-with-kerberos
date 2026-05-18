FROM bde2020/hive:2.3.2-postgresql-metastore

USER root

RUN echo "deb http://archive.debian.org/debian jessie main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid && \
    apt-get update --allow-unauthenticated && \
    apt-get install -y --allow-unauthenticated krb5-user && \
    rm -rf /var/lib/apt/lists/*

# Override startup script with Kerberos-aware version
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh
