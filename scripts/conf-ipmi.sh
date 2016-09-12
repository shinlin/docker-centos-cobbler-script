#!/bin/bash

cat RD650NIC-MAC.txt | while read LINE 
do        
    IP1=`echo $LINE|cut -d ' ' -f 7`
    IP_IMPI=`echo $LINE|cut -d ' ' -f 10`

    echo $IP1
    echo ${IP_IMPI}

    ssh root@${IP1} << REMOTE_END
    ipmitool lan set 1 ipsrc static
    ipmitool lan set 1 ipaddress ${IP_IMPI} 
    ipmitool lan set 1 netmask 255.255.0.0
    sleep 3

    # set your password 
    ipmitool user set password 2 your_password
    sleep 2

    ipmitool -I lan -H  ${IP_IMPI} -U lenovo -P your_password  lan print 1
    sleep 2
    
    exit 0
REMOTE_END
        
done


