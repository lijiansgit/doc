#start
echo "开始前需要做的工作:"
echo "1.本机IP为：10.0.0.10 则执行grep -rl HOSTIP ./ |xargs sed -i 's/HOSTIP/10.0.0.10/g' "
echo "2. --insecure-registry hub.test.cn "
echo "3. wget flannel bin from https://github.com/coreos/flannel/releases/ to /usr/loca/bin"
echo "4. wget k8s bin from https://kubernetes.io/docs/setup/release/notes/ to /usr/loca/bin"
#

#yum
yum install -y libnetfilter_conntrack-devel libnetfilter_conntrack conntrack-tools ipvsadm wget
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
