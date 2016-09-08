#!/bin/bash

function add_single_system() {
# add one system with multiple NICs
# input parameters format:
# system_name profile host_name MAC0 IP0 MAC1 IP1 MAC2 IP2 MAC3 IP3 NETMASK GATEWAY
    system_name=$1
    profile=$2 
    host_name=$3 
    MAC0=$4
    IP0=$5 
    MAC1=$6 
    IP1=$7
    MAC2=$8 
    IP2=$9 
    MAC3=${10}
    IP3=${11}
    NETMASK=${12}
    GATEWAY=${13}

    cobbler system remove --name=${system_name}
    cobbler system add \
    --name=${system_name} \
    --profile=${profile} \
    --hostname=${host_name} \
    --name-servers=203.95.1.2 \
    --interface=eth0 \
    --mac=${MAC0} \
    --static=1 \
    --ip-address=${IP0} \
    --subnet=${NETMASK}

    cobbler system edit \
    --name=${system_name} \
    --interface=eth1 \
    --mac=${MAC1} \
    --static=1 \
    --ip-address=${IP1} \
    --subnet=${NETMASK}

    cobbler system edit \
    --name=${system_name} \
    --interface=eth2 \
    --mac=${MAC2} \
    --static=1 \
    --management=true \
    --if-gateway=${GATEWAY} \
    --ip-address=${IP2}\
    --subnet=${NETMASK}

    cobbler system edit \
    --name=${system_name} \
    --interface=eth3 \
    --mac=${MAC3} \
    --static=1 \
    --ip-address=${IP3} \
    --subnet=${NETMASK}

}

cat RD650NIC-MAC.txt | while read LINE 
do        
    system_name_ID=`echo $LINE|cut -d ' ' -f 1`
    system_name="system-${system_name_ID}"
    profile="centos72-1511-istack-thinkserver"
    host_name="thinkserver-${system_name_ID}"
    NETMASK="255.255.255.0"
    GATEWAY="192.168.1.1"

    MAC0=`echo $LINE|cut -d ' ' -f 2`
    MAC1=`echo $LINE|cut -d ' ' -f 3`
    MAC2=`echo $LINE|cut -d ' ' -f 4`
    MAC3=`echo $LINE|cut -d ' ' -f 5`

    IP0=`echo $LINE|cut -d ' ' -f 6`
    IP1=`echo $LINE|cut -d ' ' -f 7`
    IP2=`echo $LINE|cut -d ' ' -f 8`
    IP3=`echo $LINE|cut -d ' ' -f 9`
        
    add_single_system ${system_name} ${profile} ${host_name}  ${MAC0} ${IP0} ${MAC1} ${IP1} ${MAC2} ${IP2} ${MAC3} ${IP3} ${NETMASK} ${GATEWAY}
done


