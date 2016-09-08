#version=RHEL7
# System authorization information
auth --enableshadow --passalgo=sha512

# Use CDROM installation media
cdrom
install
#nfs --server=10.200.46.3 --dir=/data/sys/
# Run the Setup Agent on first boot
firstboot --disable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
#SELinux configuration
selinux --disabled
# Network information
network  --bootproto=dhcp --device=eth0 --onboot=off --ipv6=auto
network  --bootproto=dhcp --device=eth1 --onboot=off --ipv6=auto
network  --bootproto=dhcp --device=eth2 --onboot=off --ipv6=auto
network  --bootproto=dhcp --device=eth3 --onboot=off --ipv6=auto
network  --device=lo --hostname=localhost.localdomain
# Root password
rootpw --iscrypted $1$2skxw8Ku$KAFm48bta2G2egcUl9inR/

# System timezone
timezone Asia/Shanghai --isUtc --nontp
user --name=inesa --password=$1$2skxw8Ku$KAFm48bta2G2egcUl9inR/ --iscrypted --gecos="inesa"
# X Window System configuration information
xconfig  --startxonboot
#system bootloader configuration
bootloader --location=mbr --boot-drive=sda
zerombr
# Partition clearing information
#clearpart --all --initlabel
clearpart --drives=sda --all --initlabel
# Disk partitioning information
part /boot/efi --fstype=efi --grow --maxsize=200 --size=20
#part biosboot --fstype=biosboot --size=1
#part /boot/efi --fstype="efi" --ondisk=sda --size=500 --fsoptions="umask=0077,shortname=winnt"
part pv.19 --fstype="lvmpv" --ondisk=sda --size=850000
part /boot --fstype="xfs" --ondisk=sda --size=1999
volgroup centos --pesize=4096 pv.19
logvol swap  --fstype="swap" --size=9000 --name=swap --vgname=centos
logvol /home  --fstype="xfs" --size=40000 --name=home --vgname=centos
logvol /  --fstype="xfs" --size=800000 --name=root --vgname=centos
reboot

%packages
@base
@core
@desktop-debugging
@dial-up
@directory-client
@fonts
@gnome-desktop
@guest-agents
@guest-desktop-agents
@input-methods
@internet-browser
@java-platform
@multimedia
@network-file-system-client
@print-client
@x11
iptables-services
expect
OpenIPMI
ipmitool

%end

%post --log=/root/ks-post.log
exec >/root/ks-post-anaconda.log 2>&1
tail -f /root/ks-post-anaconda.log >/dev/tty7 &
/usr/bin/chvt 7
cat << EOF > /etc/init.d/ondemand
#! /bin/bash
# ondemand sets cpu govermor
# chkconfig: 2345 10 90
# description: Set the CPU Frequency Scaling governor to "performance"
### BEGIN INIT INFO
# Provides: $ondemand
### END INIT INFO
PATH=/sbin:/usr/sbin:/bin:/usr/bin
case "\$1" in
    start)
        for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        do
                [ -f \$CPUFREQ ] || continue
                echo -n performance > \$CPUFREQ
        done
        for SSD in /sys/block/sd[b,c,d]/queue/scheduler
        do 
                [ -f \$SSD ] || continue
                echo -n noop > \$SSD
        done
        for OSDDISK in /sys/block/$sd*/queue/read_ahead_kb
        do
                [ -f \$OSDDISK ] || continue
                /usr/bin/echo -n 8192 > \$OSDDISK
        done
        ;;
    restart|reload|force-reload)
        echo "Error: argument '$1' not supported" >&2
        exit 3
        ;;
    stop)
        ;;
    *)
        echo "Usage: $0 start|stop" >&2
        exit 3
        ;;
esac
EOF
/usr/bin/chmod +x /etc/init.d/ondemand
/usr/sbin/chkconfig ondemand on
/usr/bin/echo "MTU=9000" >> /etc/sysconfig/network-scripts/ifcfg-eth2
/usr/bin/echo "MTU=9000" >> /etc/sysconfig/network-scripts/ifcfg-eth3
/usr/bin/echo "kernel.pid_max = 4194303" >> /etc/sysctl.conf
/usr/bin/echo "vm.swappiness = 0" >> /etc/sysctl.conf
/usr/bin/systemctl disable NetworkManager
/usr/bin/systemctl disable firewalld
/usr/bin/systemctl enable iptables
/usr/bin/sed -i "s/rhgb quiet/numa=off rhgb quiet/" /etc/default/grub
/usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg
%end
