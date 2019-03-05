yum install centos-release-gluster -y
yum install -y glusterfs glusterfs-server glusterfs-fuse glusterfs-rdma
systemctl start glusterd.service
systemctl enable glusterd.service
mkdir -pv /data/gluster/prometheus
mkdir -pv /data/gluster/grafana
chmod -R 777 /data/gluster/
gluster volume create vol-prometheus yun:/data/gluster/prometheus force
gluster volume start vol-prometheus
gluster volume quota vol-prometheus enable
gluster volume quota vol-prometheus limit-usage / 10GB
gluster volume create vol-grafana yun:/data/gluster/grafana force
gluster volume start vol-grafana
gluster volume quota vol-grafana enable
gluster volume quota vol-grafana limit-usage / 5GB
#gluster volume set vol performance.io-thread-count 4
#gluster volume set vol network.ping-timeout 10
#gluster volume set vol performance.write-behind-window-size 2MB
gluster volume list
gluster volume info

#mount -t glusterfs yun:vol /test
