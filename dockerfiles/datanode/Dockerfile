FROM bde2020/hadoop-datanode:2.0.0-hadoop2.7.4-java8

USER root

RUN echo "deb http://archive.debian.org/debian jessie main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid && \
    apt-get update --allow-unauthenticated && \
    apt-get install -y --allow-unauthenticated krb5-user && \
    rm -rf /var/lib/apt/lists/*

# Generate self-signed SSL certificate for HTTPS
RUN mkdir -p /etc/hadoop/ssl
RUN keytool -genkeypair -keystore /etc/hadoop/ssl/keystore.jks -alias datanode -keyalg RSA -keysize 2048 -validity 3650 -storepass changeit -keypass changeit -dname "CN=datanode,OU=Hadoop,O=Hadoop,L=Default,ST=Default,C=US"
RUN keytool -exportcert -keystore /etc/hadoop/ssl/keystore.jks -alias datanode -storepass changeit -file /tmp/datanode.crt
RUN keytool -importcert -keystore /etc/hadoop/ssl/truststore.jks -alias datanode -storepass changeit -file /tmp/datanode.crt -noprompt
RUN rm /tmp/datanode.crt && chmod 644 /etc/hadoop/ssl/keystore.jks /etc/hadoop/ssl/truststore.jks

# Configure SSL settings
COPY ssl-server.xml /etc/hadoop/ssl-server.xml
