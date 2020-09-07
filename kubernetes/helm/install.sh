# install helm
yum install wget -y
wget https://get.helm.sh/helm-v3.3.1-linux-amd64.tar.gz -O /tmp/helm.tar.gz
tar xf /tmp/helm.tar.gz
mv linux-amd64/helm /sbin/
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm completion bash >> /etc/profile.d/k8s.sh
source /etc/profile.d/k8s.sh