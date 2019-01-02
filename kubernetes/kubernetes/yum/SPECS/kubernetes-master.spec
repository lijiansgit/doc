%define debug_package %{nil}
%global _python_bytecompile_errors_terminate_build 0
Name: kubernetes-master
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

%description
Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.

%prep
rm -rf %_topdir/BUILD/kubernetes

%build

# 安装前需修改的配置文件
%install
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/etc/kubernetes
cp -r %_topdir/SOURCES/kubernetes-master/bin/* %{buildroot}/usr/local/bin/
cp -r %_topdir/SOURCES/kubernetes-master/config/* %{buildroot}/etc/kubernetes/
mkdir -p %{buildroot}/usr/lib/systemd/system
%{__install} -p -D -m 0644 %_topdir/SOURCES/kubernetes-master/kube-apiserver.service %{buildroot}/usr/lib/systemd/system/kube-apiserver.service
%{__install} -p -D -m 0644 %_topdir/SOURCES/kubernetes-master/kube-controller-manager.service %{buildroot}/usr/lib/systemd/system/kube-controller-manager.service
%{__install} -p -D -m 0644 %_topdir/SOURCES/kubernetes-master/kube-scheduler.service %{buildroot}/usr/lib/systemd/system/kube-scheduler.service

#rpm安装后执行的脚本
%post
if [ $1 == 1 ];then
    source /etc/profile
    swapoff -a
    systemctl daemon-reload > /dev/null 2>&1
    systemctl enable kube-apiserver > /dev/null 2>&1
    systemctl enable kube-controller-manager > /dev/null 2>&1
    systemctl enable kube-scheduler > /dev/null 2>&1
    echo "start kube-apiserver..."
    systemctl start kube-apiserver
    echo "start kube-controller-manager..."
    systemctl start kube-controller-manager
    echo "start kube-scheduler..."
    systemctl start kube-scheduler
    swapoff -a    
fi

if [ $1 == 2 ]; then
   echo "test"
fi

#rpm卸载前执行的脚本
%preun
if [ $1 == 0 ];then
    systemctl stop kube-apiserver > /dev/null 2>&1
    systemctl stop kube-controller-manager > /dev/null 2>&1
    systemctl stop kube-scheduler > /dev/null 2>&1
    systemctl disable kube-controller-manager
    systemctl disable kube-scheduler
    systemctl disable kube-apiserver
fi

%clean
rm -rf %{buildroot}

%files
/usr/local/bin
/etc/kubernetes
/usr/lib/systemd/system/kube-apiserver.service
/usr/lib/systemd/system/kube-controller-manager.service
/usr/lib/systemd/system/kube-scheduler.service

%changelog
* Mon Aug  6 2018 LiJian <jianli@test.com> master
- Initial version
