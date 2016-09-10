# docker build --rm -t rhel7/automount-nfs .
# docker run -tdi --cap-add SYS_ADMIN rhel7/automount-nfs
# docker run -tdi --cap-add SYS_ADMIN --security-opt label:type:docker_t rhel7/automount-nfs
# TEST - docker exec {container} ls -la mnt/$MNTPOINT
#       e.g. docker exec nfsmount ls -la mnt/nfstest

FROM registry.access.redhat.com/rhel7
MAINTAINER Tommy Hughes <tohughes@redhat.com>

ENV FSERVERIP=10.1.10.223 \
    FSMNT=/var/export/nfstest \
    MNTPOINT=nfstest \
    FSUSER=nfstest \
    UID_GID=2001 \
    MNTTYPE=nfs4

RUN set -x \
    && groupadd -r $FSUSER -g $UID_GID && useradd -u $UID_GID -r -g $FSUSER -m -c "$FSUSER User" -d /home/$FSUSER $FSUSER \
    && yum-config-manager --enable rhel-7-server-rpms \
    && yum -y install deltarpm \
    && yum -y update \
    && echo "installing necessary packages" \
    && yum -y install autofs iputils nfs-utils fuse sudo \
    && yum clean all \
    && echo "$FSUSER   ALL= NOPASSWD: /usr/sbin/automount" >> /etc/sudoers \
    && echo "/home/$FSUSER/mnt	/etc/auto.home" >> /etc/auto.master \
    && echo "$MNTPOINT    -fstype=$MNTTYPE,rw,soft,intr,rsize=8192,wsize=8192    $FSERVERIP:$FSMNT" > /etc/auto.home \
    && sed -i '/automount:/d' /etc/nsswitch.conf \
    && echo "automount:  files" >> /etc/nsswitch.conf

USER $FSUSER
RUN mkdir -p /home/$FSUSER/mnt
WORKDIR /home/$FSUSER
CMD sudo automount -f