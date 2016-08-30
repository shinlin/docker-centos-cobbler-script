FROM local/c7-systemd
MAINTAINER "liumk" <ldreamk@hotmail.com>

#installation
RUN yum install -y epel-release
RUN yum install -y dhcp cobbler cobbler-web 

#enable service
RUN systemctl enable dhcpd
RUN systemctl enable httpd
RUN systemctl enable tftp
RUN systemctl enable cobblerd

#RUN cobbler get-loaders
RUN sed -i -e 's/\(^.*disable.*=\) yes/\1 no/' /etc/xinetd.d/tftp
RUN systemctl enable rsyncd.service
RUN yum install -y which initscripts wget pykickstart fence-agents
RUN wget ftp://rpmfind.net/linux/epel/5/x86_64/debmirror-20090807-1.el5.noarch.rpm && yum localinstall -y debmirror-20090807-1.el5.noarch.rpm 

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

