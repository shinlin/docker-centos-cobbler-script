systemctl restart cobblerd
sleep 1
cobbler check
cobbler sync
systemctl restart cobblerd
systemctl restart dhcpd
