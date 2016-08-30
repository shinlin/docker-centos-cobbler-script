source ../set-env.sh

#mod config
docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} sed -i 's/^default_password_crypted:.*$/default_password_crypted: "$1$qgLnBuO7$XlmK82\/FC\/hMohhoK7UiB."/' /etc/cobbler/settings
docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} sed -i "s/^server:.*$/server: ${DOCKER_COBBLER_IP}/" /etc/cobbler/settings
docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} sed -i "s/^next_server:.*$/next_server: ${DOCKER_COBBLER_IP}/" /etc/cobbler/settings
docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} sed -i 's/^manage_dhcp:.*$/manage_dhcp: 1/' /etc/cobbler/settings

docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} sed -i "s/^ *option routers             192.168.1.5;/     option routers             ${DOCKER_COBBLER_ROUTE};/" /etc/cobbler/dhcp.template
docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} sed -i "s/^ *range dynamic-bootp        192.168.1.100 192.168.1.254;/     range dynamic-bootp        ${DOCKER_COBBLER_DHCP_START} ${DOCKER_COBBLER_DHCP_END};/" /etc/cobbler/dhcp.template

docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} sed -i "s/^dists/#dists/" /etc/debmirror.conf
docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} sed -i "s/^arches/#arches/" /etc/debmirror.conf

docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} systemctl restart cobblerd
sleep 2
docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} cobbler check
docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} cobbler sync
docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} systemctl restart dhcpd
docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} cobbler import --name=centos72-1511 --arch=x86_64 --path=/mnt

#htdigest /etc/cobbler/users.digest "Cobbler" <username>
#docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} htdigest /etc/cobbler/users.digest "Cobbler" cobbler
docker exec -it ${DOCKER_COBBLER_CONTAIN_NAME} sed -i "s/^cobbler:.*$/cobbler:Cobbler:5a044e3c693d509f6f78999829ce6e2c/" /etc/cobbler/users.digest
