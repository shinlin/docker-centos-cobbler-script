#!/bin/bash

docker rm -f  $(docker ps -a|awk '{print $1}'|grep -v CON)
#brctl delif ovs-br0 eth0
ovs-vsctl del-port br0 eth0
PXEID=$(docker run -d --net none --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name centos-cobbler-v0.6.3 test/centos-cobbler:v0.6)
pipework ovs-br0 $PXEID 192.168.1.114/24@192.168.1.1

ifconfig eth0 0
ifconfig ovs-br0 192.168.1.112/24
#brctl addif br0 eth0
ovs-vsctl add-port ovs-br0 eth0
route add default gateway 192.168.1.1 dev ovs-br0

nsenter --mount --uts --ipc --net --pid --target $(docker inspect --format "{{.State.Pid}}" "$PXEID")
