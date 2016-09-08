
cobbler system remove --name=system-thinkserver-PC0EQQ67 

cobbler system add \
--name=system-thinkserver-PC0EQQ67 \
--profile=centos72-1511-istack-thinkserver \
--hostname=thinkserver-PC0EQQ67 \
--name-servers=203.95.1.2 \
--interface=eth0 \
--mac=A0:36:9F:9B:34:C6 \
--static=1 \
--ip-address=192.168.11.139 \
--subnet=255.255.255.0

cobbler system edit \
--name=system-thinkserver-PC0EQQ67 \
--interface=eth1 \
--mac=A0:36:9F:9B:34:C7 \
--static=1 \
--ip-address=192.168.12.139 \
--subnet=255.255.255.0

cobbler system edit \
--name=system-thinkserver-PC0EQQ67 \
--interface=eth2 \
--mac=68:05:CA:31:D5:CD \
--static=1 \
--management=true \
--if-gateway=192.168.1.1 \
--ip-address=192.168.1.139 \
--subnet=255.255.255.0

cobbler system edit \
--name=system-thinkserver-PC0EQQ67 \
--interface=eth3 \
--mac=68:05:CA:31:D5:CC \
--static=1 \
--ip-address=192.168.2.139 \
--subnet=255.255.255.0

