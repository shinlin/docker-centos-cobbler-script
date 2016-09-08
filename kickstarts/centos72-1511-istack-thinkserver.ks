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
timezone  Asia/Shanghai --isUtc --nontp
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

# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('kickstart_done')
# End final steps
%end
