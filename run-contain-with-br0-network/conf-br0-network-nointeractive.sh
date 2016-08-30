#!/bin/bash

docker rm -f  $(docker ps -a|awk '{print $1}'|grep -v CON)
brctl delif br0 eth0
PXEID=$(docker run -d --net none --privileged -v /dist/centos:/mnt:ro -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name centos-cobbler-192-v0.2 test/c7-cobbler:v0.2)
pipework br0 $PXEID 192.168.1.124/24

ifconfig eth0 0
ifconfig br0 192.168.1.122/24
brctl addif br0 eth0
route add default gateway 192.168.1.1 dev br0

#nsenter --mount --uts --ipc --net --pid --target $(docker inspect --format "{{.State.Pid}}" "$PXEID")
