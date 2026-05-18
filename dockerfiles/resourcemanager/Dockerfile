FROM bde2020/hadoop-resourcemanager:2.0.0-hadoop2.7.4-java8

USER root

RUN echo "deb http://archive.debian.org/debian jessie main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid && \
    apt-get update --allow-unauthenticated && \
    apt-get install -y --allow-unauthenticated krb5-user && \
    rm -rf /var/lib/apt/lists/*
