# docker build --rm -t rhel7/nfstest .
# docker run -tdi --cap-add SYS_ADMIN --device /dev/fuse rhel7/nfstest
# TEST - docker exec {container} ls -la /misc/nfstest

FROM registry.access.redhat.com/rhel7
MAINTAINER Tommy Hughes <tohughes@redhat.com>

RUN set -x \
    && groupadd -r nfsnobody -g 65534 && useradd -u 65534 -r -g nfsnobody -m -s /sbin/nologin -c "Anonymous NFS User" -d /var/lib/nfs nfsnobody \
    && echo "%nfsnobody   ALL= NOPASSWD: /usr/sbin/automount" >> /etc/sudoers \
    && yum -y update \
    && echo "installing necessary packages" \
    && yum -y install autofs iputils nfs-utils fuse sudo \
    && yum clean all \
    && mkdir /misc \
    && echo "nfstest     -fstype=nfs,rw,soft,intr,rsize=8192,wsize=8192       10.1.10.223:/var/export/nfstest" >> /etc/auto.misc \
    && sed -i '/automount/d' /etc/nsswitch.conf \
    && echo "automount:  files" >> /etc/nsswitch.conf

USER nfsnobody
WORKDIR /
CMD sudo automount -f