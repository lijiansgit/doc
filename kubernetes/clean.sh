#清理工作

#worker
for I in flanneld kube-proxy kubelet docker;do
	systemctl disable ${I}
	echo "stop ${I}..."
	systemctl stop ${I}
done
yum remove docker -y
mv /usr/lib/systemd/system/kube* /tmp/
mv /usr/lib/systemd/system/flanneld.service /tmp/
mv /etc/kubernetes /tmp/

#master
for I in kube-apiserver kube-controller-manager kube-scheduler flanneld kube-proxy kubelet etcd docker;do
	systemctl disable ${I}
	echo "stop ${I}..."
	systemctl stop ${I}
done
yum remove etcd docker -y
mv /usr/lib/systemd/system/kube* /tmp/
mv /usr/lib/systemd/system/flanneld.service /tmp/
mv /etc/kubernetes /tmp/

#clean binary file
# rm -rf /usr/local/bin/kube*
# rm -rf /usr/local/bin/cfssl*
# rm -rf /usr/local/bin/flanneld
# rm -rf /usr/local/bin/mk-docker-opts.sh
