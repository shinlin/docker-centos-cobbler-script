mkdir -p /dist/centos
mount -t iso9660 -o loop /root/CentOS-7-x86_64-DVD-1511.iso /dist/centos/
docker exec -it centos-cobbler-192-v0.2 cobbler check
docker exec -it centos-cobbler-192-v0.2 cobbler sync
docker exec -it centos-cobbler-192-v0.2 cobbler import --name=centos72-1511 --arch=x86_64 --path=/mnt
#htdigest /etc/cobbler/users.digest "Cobbler" <username>
docker exec -it centos-cobbler-192-v0.2 htdigest /etc/cobbler/users.digest "Cobbler" cobbler

