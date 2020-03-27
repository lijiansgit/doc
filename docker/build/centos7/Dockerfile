FROM centos:centos7.7.1908

LABEL MAINTAINER="lijian"

ENV REPO_URL="https://mirrors.aliyun.com/repo" \
    BUILD_DEPS="psmisc \
                net-tools \
                bind-utils \
                telnet \
                nscd \
                curl \
                sudo"

RUN ln -sfv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime               && \
    curl -o /etc/yum.repos.d/CentOS-Base.repo ${REPO_URL}/Centos-7.repo    && \
    curl -o /etc/yum.repos.d/epel.repo ${REPO_URL}/epel-7.repo             && \
    yum clean all && yum makecache fast                                    && \
    yum -y install ${BUILD_DEPS}                                           && \
    groupadd -g 500 work                                                   && \
    useradd -g 500 -u 500 work                                             && \
    yum clean all                                                          && \
    rm -rf /anaconda-post.log /var/lib/yum /root/anaconda-ks.cfg

CMD ["/bin/bash"]