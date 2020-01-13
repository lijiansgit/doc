FROM dockergogolj/centos:7.7.1908-tools
LABEL MAINTAINER="lijian"

RUN yum -y update       && \
    yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel wget && \
    yum clean all                                                   && \
    rm -rf /anaconda-post.log /var/lib/yum /root/anaconda-ks.cfg
