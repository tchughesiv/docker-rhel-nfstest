# docker build --rm -t rhel7/nfstest .
# docker run -tdi --cap-add SYS_ADMIN --device /dev/fuse rhel7/nfstest
# TEST - docker exec {container} ls -la /misc/nfstest

FROM registry.access.redhat.com/rhel7
MAINTAINER Tommy Hughes <tohughes@redhat.com>

RUN set -x \
#    && groupadd -r nfsnobody -g 65534 && useradd -u 65534 -r -g nfsnobody -m -s /sbin/nologin -c "Anonymous NFS User" -d /var/lib/nfs nfsnobody \
    && groupadd -r nfsnobody -g 65534 && useradd -u 65534 -r -g nfsnobody -m -c "Anonymous NFS User" -d /var/lib/nfs nfsnobody \
    && echo "%nfsnobody   ALL= NOPASSWD: /usr/sbin/automount" >> /etc/sudoers \
    && yum-config-manager --enable rhel-7-server-rpms \
    && yum -y install deltarpm \
    && yum -y update \
    && echo "installing necessary packages" \
    && yum -y install autofs iputils nfs-utils fuse sudo \
#    && yum -y install iputils nfs-utils fuse \
    && yum clean all \
    && mkdir -p /misc \
#    && mkdir -p /nfstest \
    && echo "nfstest     -fstype=nfs,rw,soft,intr,rsize=8192,wsize=8192       10.1.10.223:/var/export/nfstest" >> /etc/auto.misc \
    && sed -i '/automount/d' /etc/nsswitch.conf \
    && echo "automount:  files" >> /etc/nsswitch.conf \
    && setcap cap_sys_admin+p /usr/sbin/automount
#    && setcap cap_sys_admin+p /usr/bin/mount \
#    && setcap cap_sys_admin+p /usr/sbin/mount.nfs

# RUN echo "10.1.10.223:/var/export/nfstest /nfstest nfs auto,proto=tcp,rw,user,rsize=8192,wsize=8192,intr" > /etc/fstab
### CMD mount /nfstest

USER nfsnobody
WORKDIR /
CMD sudo automount -f
# CMD sleep 300
