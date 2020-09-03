#start
echo "开始前需要做的工作:"
echo "1.本机IP为：10.0.0.10 则执行grep -rl HOSTIP ./ |xargs sed -i 's/HOSTIP/10.0.0.10/g' "
echo "2. --insecure-registry hub.test.cn "
echo "3. wget flannel bin from https://github.com/coreos/flannel/releases/ to /usr/loca/bin"
echo "4. wget k8s bin from https://kubernetes.io/docs/setup/release/notes/ to /usr/loca/bin"
#

#yum
yum install -y libnetfilter_conntrack-devel libnetfilter_conntrack conntrack-tools ipvsadm wget chrony
systemctl enable chronyd
systemctl start chronyd
#systctl
echo "vm.swappiness = 0" >> /etc/sysctl.conf
swapoff -a
echo "swapoff -a" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
# bug: https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
# ssl tools
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
chmod +x cfssl_linux-amd64
mv cfssl_linux-amd64 /usr/local/bin/cfssl
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssljson_linux-amd64
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x cfssl-certinfo_linux-amd64
mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
