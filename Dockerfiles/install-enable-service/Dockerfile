FROM test/c7-cobbler:v0.1
MAINTAINER "liumk" <ldreamk@hotmail.com>
#RUN yum install -y epel-release
#RUN yum install -y dhcp cobbler cobbler-web 
RUN systemctl enable dhcpd
RUN systemctl enable httpd
RUN systemctl enable tftp
RUN systemctl enable cobblerd

RUN sed -i 's/^default_password_crypted:.*$/default_password_crypted: "$1$qgLnBuO7$XlmK82\/FC\/hMohhoK7UiB."/' /etc/cobbler/settings
RUN sed -i 's/^server:.*$/server: 192.168.1.124/' /etc/cobbler/settings
RUN sed -i 's/^next_server:.*$/next_server: 192.168.1.124/' /etc/cobbler/settings
RUN sed -i 's/^manage_dhcp:.*$/manage_dhcp: 1/' /etc/cobbler/settings

RUN sed -i 's/^ *option routers             192.168.1.5;/     option routers             192.168.1.1;/' /etc/cobbler/dhcp.template
RUN sed -i 's/^ *range dynamic-bootp        192.168.1.100 192.168.1.254;/     range dynamic-bootp        192.168.1.152 192.168.1.162;/' /etc/cobbler/dhcp.template

#RUN systemctl start cobblerd

#RUN cobbler get-loaders
RUN sed -i -e 's/\(^.*disable.*=\) yes/\1 no/' /etc/xinetd.d/tftp
RUN systemctl enable rsyncd.service
RUN yum install -y which
RUN yum install -y initscripts
RUN yum install -y wget 
RUN yum install -y pykickstart  
#RUN yum install -y fence-agents
#RUN wget ftp://rpmfind.net/linux/epel/5/x86_64/debmirror-20090807-1.el5.noarch.rpm && yum localinstall -y debmirror-20090807-1.el5.noarch.rpm 

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

