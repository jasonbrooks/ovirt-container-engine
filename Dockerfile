# vim: set et sts=4:
FROM docker.io/centos:centos7

MAINTAINER "Fabian Deutsch" <fabiand@redhat.com>

ENV container docker

# Upgrade CentOS
RUN yum -y makecache fast && yum -y update && yum clean all

# Install oVirt Engine
RUN yum install -y http://plain.resources.ovirt.org/pub/yum-repo/ovirt-release36.rpm
RUN yum install --nogpgcheck -y ovirt-engine

# Enable autologin of root
RUN sed "/^ExecStart/ s/agetty/agetty -a root/" /usr/lib/systemd/system/console-getty.service > /etc/systemd/system/console-getty.service

EXPOSE 80
EXPOSE 443

# Persist these dirs
VOLUME ["/etc", "/var"]

# Start systemd
CMD ["/usr/sbin/init"]

# Copy in some data
COPY data/*-answers /root/
RUN mkdir /container
COPY container/* /container/

# To install we run a 'transient' container which will be removed afterwards again.
# We need to do this to get to the atomic-install command inside the image.
# To operate with the hosts docker, we pass in the host fs.
LABEL INSTALL docker run \
    --rm \
    -v /:/host \
    -e FQDN=\$(hostname) -e ADMINPASSWORD=\${ADMINPW:-ovirt} -e NAME=NAME -e IMAGE=IMAGE \
    IMAGE container/atomic-install.sh

LABEL RUN docker start NAME

#LABEL RUN-W-VOLS docker run --name engine --rm --volumes-from engine-data -p 443:443 -p 80:80 --cap-add=ALL -v /sys/fs/cgroup:/sys/fs/cgroup:ro -it docker.io/fabiand/engine


