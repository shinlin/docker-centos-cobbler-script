#!/bin/bash

docker rm -f  $(docker ps -a|awk '{print $1}'|grep -v CON)
brctl delif br0 eth0
PXEID=$(docker run -d --net none --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name centos-cobbler-192-v0.1.1 test/centos-cobbler:v1.0)
#pipework br0 $PXEID 192.168.1.114/24@192.168.1.1
pipework br0 $PXEID 192.168.1.114/24

ifconfig eth0 0
ifconfig br0 192.168.1.112/24
brctl addif br0 eth0
route add default gateway 192.168.1.1 dev br0

nsenter --mount --uts --ipc --net --pid --target $(docker inspect --format "{{.State.Pid}}" "$PXEID")
