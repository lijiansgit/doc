docker run -d --name centos \
    --env-file base.env \
    -v d:/linux:/data \
    -v d:/gocode:/gocode \
    dockergogolj/centos:7.6.1810-test-clt