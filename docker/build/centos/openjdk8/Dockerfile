FROM dockergogolj/centos:7.7.1908

LABEL MAINTAINER="lijian"

ENV BUILD_DEPS="java-1.8.0-openjdk \
                java-1.8.0-openjdk-devel"

RUN yum -y install ${BUILD_DEPS}    && \
    yum clean all                   && \
    rm -rf /anaconda-post.log /var/lib/yum /root/anaconda-ks.cfg

CMD ["/bin/bash"]
