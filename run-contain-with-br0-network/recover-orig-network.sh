#!/bin/bash

docker rm -f  $(docker ps -a|awk '{print $1}'|grep -v CON)
brctl delif br0 eth0

ifconfig br0 0
brctl delif br0 eth0
ifconfig eth0 192.168.1.122/24
route del default gateway 192.168.1.1 
route add default gateway 192.168.1.1 dev eth0
