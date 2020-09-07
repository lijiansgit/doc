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
yum install -y \
  containerd.io-1.2.13 \
  docker-ce-19.03.11 \
  docker-ce-cli-19.03.11
## 创建 /etc/docker 目录。
mkdir -p /etc/docker
# 设置 daemon。
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
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
systemctl restart docker

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

# https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
modprobe br_netfilter
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
# worker 节点执行到这里即可

# default cgroup-driver: systemd
# echo "KUBELET_EXTRA_ARGS=--cgroup-driver=systemd" > /etc/sysconfig/kubelet

# install
# kubeadm init --dry-run
# bak: --image-repository registry.cn-hangzhou.aliyuncs.com/mirror-overseas
kubeadm init --kubernetes-version=1.19.0 \
    --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers \
    --pod-network-cidr 10.244.0.0/16 \
    --service-cidr 10.96.0.0/12

echo "-------------------注意上述命令会出现增加多个worker节点的命令和token信息"

# verify
kubectl completion bash > /etc/profile.d/k8s.sh
chmod +x /etc/profile.d/k8s.sh
source  /etc/profile.d/k8s.sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl version
kubectl  cluster-info

# install network plugin
kubectl apply -f kube-flannel.yml
kubectl get nodes
kubectl -n kube-system get pods

exit