# docker build --rm -t rhel7/nfsmount .
# need docker fixes first ## docker run -tdi --cap-add SYS_ADMIN rhel7/nfsmount
# docker run -tdi --privileged rhel7/nfsmount
# TEST - docker exec {container} ls -la $MNTPOINT
#       e.g. docker exec nfsmount ls -la mnt/

FROM registry.access.redhat.com/rhel7
MAINTAINER Tommy Hughes <tohughes@redhat.com>

ENV FSERVERIP=10.1.10.223 \
    FSERVERHOSTNAME=nfstest.test.com \
    FSMNT=/var/export/nfstest \
    FSUSER=nfstest \
    UID_GID=2001

# mount point MUST be in user's home dir
ENV MNTPOINT=/home/$FSUSER/mnt

RUN set -x \
    && groupadd -r $FSUSER -g $UID_GID && useradd -u $UID_GID -r -g $FSUSER -m -c "$FSUSER User" -d /home/$FSUSER $FSUSER \
    && yum-config-manager --enable rhel-7-server-rpms \
    && yum -y install deltarpm \
    && yum -y update \
    && echo "installing necessary packages" \
    && yum -y install iputils nfs-utils sudo \
    && yum clean all \
    && echo "$FSUSER   ALL= NOPASSWD: /usr/bin/nfsmount" > /etc/sudoers.d/$FSUSER

ADD nfsmount /usr/bin/
RUN chmod 755 /usr/bin/nfsmount

USER $FSUSER
RUN mkdir $MNTPOINT
WORKDIR /home/$FSUSER
CMD sudo nfsmount $FSERVERIP:$FSMNT $MNTPOINT