# docker build --rm -t rhel7/nfstest .
# docker run -tdi --cap-add SYS_ADMIN --device /dev/fuse rhel7/nfstest
# TEST - docker exec {container} ls -la $MNTPOINT

FROM registry.access.redhat.com/rhel7
MAINTAINER Tommy Hughes <tohughes@redhat.com>

ENV MNTPOINT=/nfstest \
    NFSUSER=nfstest \
    UID_GID=2001

RUN set -x \
    && groupadd -r $NFSUSER -g $UID_GID && useradd -u $UID_GID -r -g $NFSUSER -m -c "$NFSUSER User" -d /home/$NFSUSER $NFSUSER \
    && mkdir -p /home/$NFSUSER/.ssh \
    && chown $NFSUSER:$NFSUSER /home/$NFSUSER/.ssh \
    && chmod 700 /home/$NFSUSER/.ssh \
    && curl -o epel-release-latest-7.noarch.rpm -SL https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --retry 999 --retry-max-time 0 -C - \
    && rpm -ivh epel-release-latest-7.noarch.rpm \
    && rm epel-release-latest-7.noarch.rpm \
    && yum-config-manager --enable rhel-7-server-rpms \
    && yum -y install deltarpm \
    && yum -y update \
    && echo "installing necessary packages" \
    && yum -y install iputils fuse-sshfs fuse \
    && yum clean all \
    && mkdir -p $MNTPOINT \
    && chown $NFSUSER:$NFSUSER $MNTPOINT \
    && chmod 4755 /usr/bin/fusermount

COPY id_rsa /home/$NFSUSER/.ssh/
RUN chown $NFSUSER:$NFSUSER /home/$NFSUSER/.ssh/id_rsa \
    && chmod 600 /home/$NFSUSER/.ssh/id_rsa

USER $NFSUSER
WORKDIR /home/$NFSUSER

CMD sshfs -f $NFSUSER@10.1.10.223:/var/export/nfstest $MNTPOINT -o IdentityFile=/home/$NFSUSER/.ssh/id_rsa -o reconnect -o workaround=all
# mknod -m 666 dev/fuse c 10 229
