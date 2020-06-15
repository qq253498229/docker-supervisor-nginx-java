FROM ubuntu:16.04

MAINTAINER 王斌 <253498229@qq.com>

ENV TZ=Asia/Shanghai
COPY config/sources.list /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN apt-get install -y curl wget

# Java
RUN wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u252-b09/OpenJDK8U-jre_x64_linux_hotspot_8u252b09.tar.gz
RUN tar -xf OpenJDK8U-jre_x64_linux_hotspot_8u252b09.tar.gz && rm -rf OpenJDK8U-jre_x64_linux_hotspot_8u252b09.tar.gz
ENV PATH=$PWD/jdk8u252-b09-jre/bin:$PATH

# Nginx
RUN wget https://nginx.org/download/nginx-1.19.0.tar.gz
RUN tar -xf nginx-1.19.0.tar.gz && rm -rf nginx-1.19.0.tar.gz
RUN apt-get install -y net-tools libpcre3 libpcre3-dev libssl-dev gcc build-essential
RUN cd nginx-1.19.0 && ./configure --with-http_gzip_static_module && make install && cd .. && rm -rf nginx-1.19.0
RUN cat /usr/local/nginx/conf/nginx.conf

# Supervisor
RUN apt-get install -y supervisor
ADD config/supervisor.conf /app/conf/supervisord.conf

# Clean Up
RUN apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache}/* /tmp/* /var/tmp/*

# app
COPY config/nginx.conf /usr/local/nginx/conf/nginx.conf
#COPY app.jar /app/data/app.jar

VOLUME ["/app/data"]
VOLUME ["/app/conf"]
VOLUME ["/app/log"]

CMD ["supervisord", "-n", "-c", "/app/conf/supervisord.conf"]
