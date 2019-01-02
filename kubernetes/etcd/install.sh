yum install etcd -y
systemctl enable etcd
#ssl
cd ssl/
cfssl gencert --initca=true etcd-root-ca-csr.json | cfssljson --bare etcd-root-ca
cfssl gencert --ca etcd-root-ca.pem --ca-key etcd-root-ca-key.pem \
--config etcd-gencert.json etcd-csr.json | cfssljson --bare etcd
#cp
cd ../
mkdir -pv /etc/etcd/ssl
cp -pr ssl/*.pem  /etc/etcd/ssl/
chown etcd.etcd /etc/etcd/ssl/*
cp etcd.conf /etc/etcd/etcd.conf
echo "alias etcdctl='etcdctl --cert-file /etc/etcd/ssl/etcd.pem --key-file /etc/etcd/ssl/etcd-key.pem --ca-file /etc/etcd/ssl/etcd-root-ca.pem --endpoints https://127.0.0.1:2379'" >> ~/.bashrc
. ~/.bashrc
echo -e "1.请按照实际情况更改/etc/etcd/etcd.conf\n2.systemctl start etcd"
