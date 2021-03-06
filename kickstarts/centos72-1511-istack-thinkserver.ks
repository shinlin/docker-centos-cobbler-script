# kickstart template for Fedora 8 and later.
# (includes %end blocks)
# do not use with earlier distros

#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth --enableshadow --passalgo=sha512
# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
# Partition clearing information
clearpart --drives=sda --all --initlabel

# Use text mode install
text

## Firewall configuration
#firewall --enabled
# Run the Setup Agent on first boot
firstboot --disable
ignoredisk --only-use=sda
# System keyboard
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
# Use network installation
url --url=$tree
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# Network information
$SNIPPET('network_config')

#network  --bootproto=dhcp --device=eth0 --onboot=off --ipv6=auto
# Reboot after installation
reboot

#Root password
rootpw --iscrypted $default_password_crypted
# SELinux configuration
selinux --disabled
## Do not configure the X Window System
#skipx
# System timezone
# set the encrpted password such as "openssl passwd -1 "
timezone  Asia/Shanghai --isUtc --nontp
user --name=inesa --password=your_encrypted_password --iscrypted --gecos="inesa"
# X Window System configuration information
xconfig  --startxonboot
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr

## Allow anaconda to partition the system as needed
#autopart

# Disk partitioning information
part /boot/efi --fstype=efi --grow --maxsize=200 --size=20
part pv.19 --fstype="lvmpv" --ondisk=sda --size=850000
part /boot --fstype="xfs" --ondisk=sda --size=1999
volgroup centos --pesize=4096 pv.19
logvol swap  --fstype="swap" --size=9000 --name=swap --vgname=centos
logvol /home  --fstype="xfs" --size=40000 --name=home --vgname=centos
logvol /  --fstype="xfs" --size=800000 --name=root --vgname=centos

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end

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

%post --nochroot
$SNIPPET('log_ks_post_nochroot')
%end

%post
$SNIPPET('log_ks_post')
# Start yum configuration
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('func_register_if_enabled')
$SNIPPET('download_config_files')
$SNIPPET('koan_environment')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')

# special for istack
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

# Set LENOVE IMPI 
ip_impi_part=$(cat /etc/sysconfig/network-scripts/ifcfg-eth1 |grep IPADDR|awk -F "." '{print $4}' )
ip_impi="172.25.128.${ip_impi_part}"
ipmitool lan set 1 ipsrc static
ipmitool lan set 1 ipaddress ${ip_impi}
ipmitool lan set 1 netmask 255.255.0.0
# set the real password
ipmitool user set password 2 your_password 
#ipmitool -I lan -H  172.25.128.13 -U lenovo -P your_password lan print 1

# Set Network Parameter 
sed -i 's/BOOTPROTO=none/BOOTPROTO=static/g' /etc/sysconfig/network-scripts/ifcfg-eth*
echo "DNS1=203.95.1.2">>/etc/sysconfig/network-scripts/ifcfg-eth1
echo "DNS2=203.95.7.1">>/etc/sysconfig/network-scripts/ifcfg-eth1

# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('kickstart_done')
# End final steps
%end
