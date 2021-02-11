#!/bin/bash
# require centos7
# https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

set -xe

VER="1.18.8"

# init
# disable swap
echo "swapoff -a" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
swapoff -a
# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
set +xe
setenforce 0
set -xe
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
# 时间同步
yum install chrony -y
systemctl enable chronyd
systemctl start chronyd

# install docker
# 安装 Docker CE
## 设置仓库
### 安装所需包
yum install yum-utils device-mapper-persistent-data lvm2 -y
### 新增 Docker 仓库。
yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo
## 安装 Docker CE.
yum install -y docker-ce-19.03.11 docker-ce-cli-19.03.11 containerd.io-1.2.13
## 创建 /etc/docker 目录。
mkdir -p /etc/docker
# 设置 daemon。
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "20"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
# 重启 Docker
systemctl daemon-reload
systemctl enable docker
systemctl restart docker

# install kubelet kubeadm kubectl

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
yum install -y kubelet-${VER}-0 kubeadm-${VER}-0 kubectl-${VER}-0 --disableexcludes=kubernetes

# 直接下载
# 被墙
#BIN_URL="https://storage.googleapis.com/kubernetes-release/release"
#curl -L ${BIN_URL}/v${VER}/bin/linux/amd64/kubeadm -o /usr/local/bin/kubeadm
#curl -L ${BIN_URL}/v${VER}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
#curl -L ${BIN_URL}/v${VER}/bin/linux/amd64/kubelet -o /usr/local/bin/kubelet
#chmod +x /usr/local/bin/*
#cat > /usr/lib/systemd/system/kubelet.service <<EOF
#[Unit]
#Description=kubelet: The Kubernetes Node Agent
#Documentation=https://kubernetes.io/docs/
#Wants=network-online.target
#After=network-online.target
#
#[Service]
#ExecStart=/usr/local/bin/kubelet
#Restart=always
#StartLimitInterval=0
#RestartSec=10
#
#[Install]
#WantedBy=multi-user.target
#EOF
#cat > /etc/sysconfig/kubelet <<EOF
#KUBELET_EXTRA_ARGS=
#EOF

systemctl enable --now kubelet

# https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
modprobe br_netfilter
cat <<EOF >  /etc/sysctl.d/99-k8s.conf
vm.swappiness = 0
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
#优化
net.ipv4.tcp_max_syn_backlog=65535
net.core.somaxconn=65535
net.netfilter.nf_conntrack_tcp_timeout_time_wait=2
net.ipv4.tcp_rmem=4096 12582912 16777216
EOF
sysctl --system
# worker 节点执行到这里即可

# default cgroup-driver: systemd
# echo "KUBELET_EXTRA_ARGS=--cgroup-driver=systemd" > /etc/sysconfig/kubelet

# install
# kubeadm init --dry-run
# bak: --image-repository registry.cn-hangzhou.aliyuncs.com/mirror-overseas
kubeadm init --kubernetes-version=${VER} \
    --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers \
    --pod-network-cidr 10.244.0.0/16 \
    --service-cidr 10.245.0.0/16

echo "-------------------注意上述命令会出现增加多个worker节点的命令和token信息---------------"

# verify
kubectl completion bash > /etc/profile.d/k8s.sh
chmod +x /etc/profile.d/k8s.sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl version
kubectl  cluster-info

# install network plugin
kubectl apply -f kube-flannel.yml
kubectl get nodes
kubectl -n kube-system get pods

yum install bash-completion -y
source  /etc/profile.d/k8s.sh
exit
