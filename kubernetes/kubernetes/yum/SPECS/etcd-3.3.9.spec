%define debug_package %{nil}
%global _python_bytecompile_errors_terminate_build 0
Name: etcd
Version: 3.3.9
AutoReq: no
Release: 1 
Summary: etcd.

Group: Application/Server 
License: Apache 
URL: https://github.com/etcd-io/etcd/releases
Packager:  LiJian <jianli@test.com>
Vendor: test
BuildRoot: %_topdir/BUILDROOT

%description
etcd is a distributed key value store that provides a reliable way to store data across a cluster of machines.

%prep
rm -rf %_topdir/BUILD/etcd

%build

%install
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/app/etcd
mkdir -p %{buildroot}/etc/etcd
cp -r %_topdir/SOURCES/etcd/bin/* %{buildroot}/usr/local/bin/
cp -r %_topdir/SOURCES/etcd/config/* %{buildroot}/etc/etcd/
mkdir -p %{buildroot}/usr/lib/systemd/system
%{__install} -p -D -m 0644 %_topdir/SOURCES/etcd/etcd.service %{buildroot}/usr/lib/systemd/system/etcd.service

#rpm安装后执行的脚本
%post
systemctl enable etcd
systemctl start etcd

#rpm卸载前执行的脚本
%preun
if [ $1 == 0 ];then
    systemctl stop etcd > /dev/null 2>&1
    systemctl disable etcd
fi

%clean
rm -rf %{buildroot}

%files
/usr/local/bin
/etc/etcd
/app/etcd
/usr/lib/systemd/system/etcd.service

%changelog
* Mon Aug  6 2018 LiJian <jianli@test.com> 1.11.2
- Initial version
