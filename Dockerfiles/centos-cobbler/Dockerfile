FROM local/c7-systemd
MAINTAINER "liumk" <ldreamk@hotmail.com>
RUN yum install -y epel-release
RUN yum install -y dhcp cobbler cobbler-web
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

