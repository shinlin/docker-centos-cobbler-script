#!/bin/bash
source ../set-env.sh

mkdir -p /dist/centos
mount -t iso9660 -o loop ${CENTOS_DVD_ISO} /dist/centos/

docker rm -f  $(docker ps -a|awk '{print $1}'|grep -v CON)
brctl delif br0 eth0
PXEID=$(docker run -d --net none --privileged -v /dist/centos:/mnt:ro -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name ${DOCKER_COBBLER_CONTAIN_NAME} test/c7-cobbler:v0.2)
pipework br0 $PXEID ${DOCKER_COBBLER_IP}/${NETMASK_BITS}

ifconfig eth0 0
ifconfig br0 ${HOST_IP}/${NETMASK_BITS}
brctl addif br0 eth0
route add default gateway ${HOST_ROUTE} dev br0

#nsenter --mount --uts --ipc --net --pid --target $(docker inspect --format "{{.State.Pid}}" "$PXEID")
