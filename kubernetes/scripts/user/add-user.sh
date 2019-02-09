#!/bin/bash
#20190209
#lijian
#添加k8s指定命名空间只读账号

ST=`date +%s`
K8SCA=/etc/kubernetes/ssl/k8s-root-ca.pem
K8SKEY=/etc/kubernetes/ssl/k8s-root-ca-key.pem
k8SCONFIG=../../kubernetes/ssl/k8s-gencert.json
USERNAME=$1
NAMESPACE=$2
if [ "${USERNAME}" = "" -o "${NAMESPACE}" = "" ];then
  echo "no USERNAME or no NAMESPACE"
  exit 111
fi

sed -i "s/USERNAME/$USERNAME/g" user-csr.json
sed -i "s/USERNAME/$USERNAME/g" rbac-user.yaml
sed -i "s/NAMESPACE/$NAMESPACE/g" rbac-user.yaml

cfssl gencert --ca $K8SCA --ca-key $K8SKEY --config $k8SCONFIG \
  --profile kubernetes user-csr.json | cfssljson --bare $USERNAME

cp $HOME/.kube/config $HOME/.kube/config.bak.$ST
export KUBE_APISERVER="https://yun:6443"
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/k8s-root-ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER}
  --kubeconfig=$USERNAME.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=/etc/kubernetes/ssl/$USERNAME.pem \
  --embed-certs=true \
  --client-key=/etc/kubernetes/ssl/$USERNAME-key.pem
  --kubeconfig=$USERNAME.kubeconfig

kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=$USERNAME
  --kubeconfig=$USERNAME.kubeconfig

kubectl config use-context kubernetes --kubeconfig=$USERNAME.kubeconfig
kubectl create -f rbac-user.yaml

sed -i "s/$USERNAME/USERNAME/g" user-csr.json
sed -i "s/$USERNAME/USERNAME/g" rbac-user.yaml
sed -i "s/$NAMESPACE/NAMESPACE/g" rbac-user.yaml


