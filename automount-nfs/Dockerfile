# docker build --rm -t rhel7/nfstest .
# docker run -tdi --cap-add SYS_ADMIN --device /dev/fuse rhel7/nfstest
# TEST - docker exec {container} ls -la /misc/$MNTPOINT

FROM registry.access.redhat.com/rhel7
MAINTAINER Tommy Hughes <tohughes@redhat.com>

ENV FSERVERIP=10.1.10.223 \
    FSERVERHOSTNAME=nfstest.test.com \
    FSMNT=/var/export/nfstest \
    MNTPOINT=nfstest \
    FSUSER=nfstest \
    UID_GID=2001

RUN set -x \
    && groupadd -r $FSUSER -g $UID_GID && useradd -u $UID_GID -r -g $FSUSER -m -c "$FSUSER User" -d /home/$FSUSER $FSUSER \
    && yum-config-manager --enable rhel-7-server-rpms \
    && yum -y install deltarpm \
    && yum -y update \
    && echo "installing necessary packages" \
    && yum -y install autofs iputils nfs-utils fuse sudo \
    && yum clean all \
    && echo "$FSUSER   ALL= NOPASSWD: /usr/sbin/automount" >> /etc/sudoers \
    && mkdir /misc \
    && echo "$MNTPOINT    -fstype=nfs4,rw,soft,intr,rsize=8192,wsize=8192    $FSERVERIP:$FSMNT" >> /etc/auto.misc \
    && sed -i '/automount:/d' /etc/nsswitch.conf \
    && echo "automount:  files" >> /etc/nsswitch.conf
#    && setcap cap_sys_admin+p /usr/sbin/automount

USER $FSUSER
WORKDIR /home/$FSUSER
CMD sudo automount -f
