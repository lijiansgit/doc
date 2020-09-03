#!/bin/bash
# require centos7
# https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

set -xe

# init
# disable swap
echo "vm.swappiness = 0" >> /etc/sysctl.conf
echo "swapoff -a" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
swapoff -a
# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config

# install docker
yum install conntrack docker -y
systemctl enable docker
systemctl start docker

# install kubelet kubeadm kubectl
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

# bug: https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# default cgroup-driver: systemd
# echo "KUBELET_EXTRA_ARGS=--cgroup-driver=systemd" > /etc/sysconfig/kubelet

# install
kubeadm init --dry-run
kubeadm init




