# kickstart template for Fedora 8 and later.
# (includes %end blocks)
# do not use with earlier distros

#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth  --useshadow  --enablemd5
# System bootloader configuration
bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel

# Use text mode install
text

# Firewall configuration
firewall --enabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
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
# Do not configure the X Window System
skipx
# System timezone
timezone  Asia/Shanghai --isUtc --nontp
user --name=test --password=$1$fu.ead2P$daIzr14iDzaPejankn38o/ --iscrypted --gecos="test"
# X Window System configuration information
xconfig  --startxonboot
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr
# Allow anaconda to partition the system as needed
autopart

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end

%packages
@^graphical-server-environment
@base
@core
@desktop-debugging
@dial-up
@fonts
@gnome-desktop
@guest-agents
@guest-desktop-agents
@input-methods
@internet-browser
@multimedia
@print-client
@virtualization-client
@virtualization-hypervisor
@virtualization-tools
@x11
kexec-tools
iptables-services
expect

%end

%post --nochroot
$SNIPPET('log_ks_post_nochroot')
%end

%post

/usr/bin/systemctl disable NetworkManager
/usr/bin/systemctl disable firewalld
/usr/bin/systemctl enable iptables
/usr/bin/sed -i "s/rhgb quiet/numa=off rhgb quiet/" /etc/default/grub
/usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg

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
# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('kickstart_done')
# End final steps
%end
