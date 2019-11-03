# wget flannel bin from https://github.com/coreos/flannel/releases/
# wget k8s bin from https://kubernetes.io/docs/setup/release/notes/
# add node please use yum rpm
cp bin/* /usr/local/bin/
chmod +x /usr/local/bin/*
####
PWDROOT=`pwd`
ETCROOT="/etc/kubernetes"
#init system
ntpdate -u ntp.aliyun.com
#init network config
etcdctl --cert-file /etc/etcd/ssl/etcd.pem --key-file /etc/etcd/ssl/etcd-key.pem \
--ca-file /etc/etcd/ssl/etcd-root-ca.pem --endpoints https://127.0.0.1:2379 \
set /kubernetes/network/config '{"Network":"172.20.0.0/16","SubnetLen":24,"Backend":{ "Type": "vxlan", "VNI": 1 }}'
if [ $? -ne 0 ];then
	echo "etcdctl set ......."
fi
#ssl
cd ssl/
cfssl gencert -initca k8s-root-ca-csr.json | cfssljson -bare k8s-root-ca
for targetName in kubernetes admin kube-proxy; do cfssl gencert --ca k8s-root-ca.pem --ca-key k8s-root-ca-key.pem --config k8s-gencert.json --profile kubernetes $targetName-csr.json | cfssljson --bare $targetName; done
cd ../
mkdir -pv ${ETCROOT}/ssl
cp -pr ssl/*.pem  ${ETCROOT}/ssl/
cp -pr ssl/*.csr  ${ETCROOT}/ssl/
cp -pr etc/* ${ETCROOT}/
#kubeconfig 
cd ${ETCROOT}
TRANDOM=`openssl rand -hex 20`
cat > token.csv <<EOF
${TRANDOM},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF
#export KUBE_APISERVER="https://lvs.com:6443"
export KUBE_APISERVER="https://HOSTIP:6443"
# admin config
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/k8s-root-ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=/etc/kubernetes/ssl/admin.pem \
  --embed-certs=true \
  --client-key=/etc/kubernetes/ssl/admin-key.pem \
  --kubeconfig=admin.kubeconfig

kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin \
  --kubeconfig=admin.kubeconfig

kubectl config use-context kubernetes  --kubeconfig=admin.kubeconfig
mv admin.kubeconfig ~/.kube/config
###
#bootstrap.kubeconfig
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/k8s-root-ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig

kubectl config set-credentials kubelet-bootstrap \
  --token=${TRANDOM} \
  --kubeconfig=bootstrap.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig

kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

###
#kube-proxy.kubeconfig
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/k8s-root-ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=/etc/kubernetes/ssl/kube-proxy.pem \
  --client-key=/etc/kubernetes/ssl/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

###
#kubelet.kubeconfig
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/k8s-root-ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kubelet.kubeconfig

kubectl config set-credentials kubelet \
  --client-certificate=/etc/kubernetes/ssl/admin.pem \
  --client-key=/etc/kubernetes/ssl/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=kubelet.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet \
  --kubeconfig=kubelet.kubeconfig

kubectl config use-context default --kubeconfig=kubelet.kubeconfig
#dockerd
yum install docker -y
#cp flanneld bin
cp bin/mk-docker-opts.sh /usr/local/bin/mk-docker-opts.sh && chmod +x /usr/local/bin/mk-docker-opts.sh
#service and start
cp  ${PWDROOT}/service/*.service /usr/lib/systemd/system/
for I in kube-apiserver kube-controller-manager kube-scheduler flanneld docker kube-proxy kubelet;do
	systemctl enable ${I}
	echo "start ${I}..."
	systemctl start ${I}
done
