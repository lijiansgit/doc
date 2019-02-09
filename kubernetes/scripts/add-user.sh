#!/bin/bash
#20190209
#lijian
#添加k8s指定命名空间只读账号

USERNAME=$1
NAMESPACE=$2
if [ "${USERNAME}" = "" -o "${NAMESPACE}" = "" ];then
  echo "no USERNAME or no NAMESPACE"
  exit 111
fi




