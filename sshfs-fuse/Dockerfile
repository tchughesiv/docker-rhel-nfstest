# docker build --rm -t rhel7/nfstest .
# docker run -tdi --cap-add SYS_ADMIN --device /dev/fuse rhel7/nfstest
# TEST - docker exec {container} ls -la /$MNTPOINT

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
    && mkdir -p /home/$FSUSER/.ssh \
    && chown $FSUSER:$FSUSER /home/$FSUSER/.ssh \
    && chmod 700 /home/$FSUSER/.ssh \
    && curl -o epel-release-latest-7.noarch.rpm -SL https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --retry 999 --retry-max-time 0 -C - \
    && rpm -ivh epel-release-latest-7.noarch.rpm \
    && rm epel-release-latest-7.noarch.rpm \
    && yum-config-manager --enable rhel-7-server-rpms \
    && yum -y install deltarpm \
    && yum -y update \
    && echo "installing necessary packages" \
    && yum -y install iputils fuse-sshfs fuse \
    && yum clean all \
    && mkdir -p /$MNTPOINT \
    && chown $FSUSER:$FSUSER /$MNTPOINT \
    && chmod 4755 /usr/bin/fusermount

COPY id_rsa /home/$FSUSER/.ssh/
RUN chown $FSUSER:$FSUSER /home/$FSUSER/.ssh/id_rsa \
    && chmod 600 /home/$FSUSER/.ssh/id_rsa

USER $FSUSER
WORKDIR /home/$FSUSER

CMD ssh-keyscan -H $FSERVERIP > /home/$FSUSER/.ssh/known_hosts && ssh-keyscan -H $FSERVERHOSTNAME >> /home/$FSUSER/.ssh/known_hosts && sshfs -f $FSUSER@$FSERVERIP:$FSMNT /$MNTPOINT -o IdentityFile=/home/$FSUSER/.ssh/id_rsa -o reconnect -o workaround=all
