# docker build --rm -t rhel7/nfstest .
# docker run -tdi rhel7/nfstest
# TEST - docker exec {container} ls -la $MNTPOINT

FROM registry.access.redhat.com/rhel7
MAINTAINER Tommy Hughes <tohughes@redhat.com>

ENV MNTPOINT=/nfstest \
    USER=nfstest \
    UID_GID=2001

RUN set -x \
    && mkdir -p /home/$USER/.ssh \
    && chown $USER:$USER /home/$USER \
    && chmod 700 /home/$USER/.ssh \
    && groupadd -r $USER -g $UID_GID && useradd -u $UID_GID -r -g $USER -m -c "$USER User" -d /home/$USER $USER \
    && yum-config-manager --enable rhel-7-server-rpms \
    && yum -y install deltarpm \
    && yum -y update \
    && echo "installing necessary packages" \
    && yum -y install iputils sshfs fuse \
    && yum clean all \
    && mkdir -p $MNTPOINT \
    && chown $USER:$USER $MNTPOINT

USER $USER
ADD id_rsa /home/$USER/.ssh/
RUN chmod 600 /home/$USER/.ssh/id_rsa
WORKDIR /home/$USER

CMD sshfs -f $USER@10.1.10.223:/var/export/nfstest $MNTPOINT -o IdentityFile=/home/$USER/.ssh/id_rsa -o reconnect -o workaround=all
