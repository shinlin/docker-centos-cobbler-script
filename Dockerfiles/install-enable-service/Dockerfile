FROM test/c7-cobbler:v0.1
MAINTAINER "liumk" <ldreamk@hotmail.com>
#RUN yum install -y epel-release
#RUN yum install -y dhcp cobbler cobbler-web 
#RUN yum install -y pykickstart
RUN systemctl enable dhcpd
RUN systemctl enable httpd
RUN systemctl enable tftp
#RUN systemctl enable rsync
RUN systemctl enable cobblerd
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

