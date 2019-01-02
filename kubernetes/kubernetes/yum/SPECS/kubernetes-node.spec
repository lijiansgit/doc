%define debug_package %{nil}
%global _python_bytecompile_errors_terminate_build 0
Name: kubernetes-node
Version: 1.11.2
AutoReq: no
Release: 1 
Summary: K8S minion/client daemon.

Group: Application/Server 
License: Apache 
URL: https://kubernetes.io/ 
Packager:  LiJian <jianli@test.com>
Vendor: test
BuildRoot: %_topdir/BUILDROOT

Requires: container-selinux 
Requires: conntrack-tools 
Requires: docker-ce 

%description
Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.

%prep
rm -rf %_topdir/BUILD/kubernetes

%build

#安装前需运行
#etcd: etcdctl set /kubernetes/network/config '{"Network":"172.20.0.0/16","SubnetLen":24,"Backend":{ "Type": "vxlan", "VNI": 1 }}'
#从master copy以下配置文件到%_topdir/SOURCES/kubernetes-node/config/
#ssl/ config bootstrap.kubeconfig kubelet.kubeconfig kube-proxy.kubeconfig 

%install
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/app/docker
mkdir -p %{buildroot}/app/kubelet
mkdir -p %{buildroot}/etc/kubernetes
cp -r %_topdir/SOURCES/kubernetes-node/bin/* %{buildroot}/usr/local/bin/
cp -r %_topdir/SOURCES/kubernetes-node/config/* %{buildroot}/etc/kubernetes/
mkdir -p %{buildroot}/usr/lib/systemd/system
%{__install} -p -D -m 0644 %_topdir/SOURCES/kubernetes-node/kubelet.service %{buildroot}/usr/lib/systemd/system/kubelet.service
%{__install} -p -D -m 0644 %_topdir/SOURCES/kubernetes-node/flanneld.service %{buildroot}/usr/lib/systemd/system/flanneld.service
%{__install} -p -D -m 0644 %_topdir/SOURCES/kubernetes-node/kube-proxy.service %{buildroot}/usr/lib/systemd/system/kube-proxy.service

#rpm安装后执行的脚本
%post
if [ $1 == 1 ];then
    # 获取到本机IP，10.186.X.X才能获取到，请相应做出改动
    IP=$(ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep "^10\.186" | egrep -v "\.255$" | head -n 1)
    interface_name=$(ifconfig | grep "$IP" -B1  | head -1 | awk -F: '{print $1}')
    #sed -i "s@10.200.119.211@$IP@g" /etc/kubernetes/proxy 
    #sed -i "s@10.200.119.211@$IP@g" /etc/kubernetes/kubelet
    [ ! -d /run/flannel ] && mkdir /run/flannel
    cat > /usr/lib/systemd/system/docker.service << EOF 
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
EnvironmentFile=-/etc/sysconfig/docker-network
ExecStart=/usr/bin/dockerd --insecure-registry hub.test.cn --data-root=/app/docker --log-opt max-size=1024m --log-opt max-file=10 \$DOCKER_NETWORK_OPTIONS
ExecStartPost=/sbin/iptables -I FORWARD -s 0.0.0.0/0 -j ACCEPT
ExecReload=/bin/kill -s HUP \$MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitCORE=1000000
LimitNOFILE=1000000
LimitNPROC=1000000
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOF
    swapoff -a
    systemctl daemon-reload > /dev/null 2>&1
    systemctl enable docker > /dev/null 2>&1
    systemctl enable flanneld > /dev/null 2>&1
    systemctl enable kubelet > /dev/null 2>&1
    systemctl enable kube-proxy > /dev/null 2>&1
    systemctl start docker
    systemctl start flanneld 
    systemctl start kubelet
    systemctl start kube-proxy 
    swapoff -a    
fi

if [ $1 == 2 ]; then
    IP=$(ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep "^10\.51|192\.168" | egrep -v "\.255$" | head -n 1)
    interface_name=$(ifconfig | grep "$IP" -B1  | head -1 | awk -F: '{print $1}')
    #sed -i "s@10.200.119.211@$IP@g" /etc/kubernetes/proxy 
    #sed -i "s@10.200.119.211@$IP@g" /etc/kubernetes/kubelet
    systemctl restart kubelet
    systemctl restart kube-proxy
fi

#rpm卸载前执行的脚本
%preun
if [ $1 == 0 ];then
    systemctl stop kube-proxy > /dev/null 2>&1
    systemctl stop kubelet > /dev/null 2>&1
    systemctl stop flanneld > /dev/null 2>&1
    systemctl stop docker > /dev/null 2>&1
    systemctl disable docker
    systemctl disable flanneld 
    systemctl disable kubelet 
    systemctl disable kube-proxy 
fi

%clean
rm -rf %{buildroot}

%files
/usr/local/bin
/app/docker
/app/kubelet
/etc/kubernetes
/usr/lib/systemd/system/kubelet.service
/usr/lib/systemd/system/flanneld.service
/usr/lib/systemd/system/kube-proxy.service

%changelog
* Mon Aug  6 2018 LiJian <jianli@test.com> node
- Initial version
