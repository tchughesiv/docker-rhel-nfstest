# docker build --rm -t rhel7/nfsmount .
# docker run -tdi --cap-add SYS_ADMIN rhel7/nfsmount
# docker run -tdi --cap-add SYS_ADMIN --security-opt label:type:docker_t rhel7/nfsmount
# TEST - docker exec {container} ls -la $MNTPOINT
#       e.g. docker exec nfsmount ls -la mnt/

FROM registry.access.redhat.com/rhel7
MAINTAINER Tommy Hughes <tohughes@redhat.com>

ENV FSERVERIP=10.1.10.223 \
    FSMNT=/var/export/nfstest \
    FSUSER=nfstest \
    UID_GID=2001 \
    MNTTYPE=nfs

# mount point MUST be in user's home dir
ENV MNTPOINT=/home/$FSUSER/mnt

RUN set -x \
    && groupadd -r $FSUSER -g $UID_GID && useradd -u $UID_GID -r -g $FSUSER -m -c "$FSUSER User" -d /home/$FSUSER $FSUSER \
    && yum-config-manager --enable rhel-7-server-rpms \
    && yum -y install deltarpm \
    && yum -y update \
    && echo "installing necessary packages" \
#    && yum -y install iputils nfs-utils sudo policycoreutils \
    && yum -y install iputils nfs-utils sudo \
    && yum clean all \
    && echo "$FSUSER   ALL= NOPASSWD: /usr/bin/nfsmount" > /etc/sudoers.d/$FSUSER

RUN echo $'#!/bin/sh\n\
SCRIPT=$0\n\
function validate_dest {\n\
    HOMEDIR=$(eval echo ~$SUDO_USER)\n\
    echo\n\
    if [[ "$1" =~ ^${HOMEDIR}/.* ]]; then\n\
	return\n\
    else\n\
	logger $SUDO_USER attempted to ${SCRIPT} on $1\n\
	echo "you are only allowed to mount on ${HOMEDIR}"\n\
	exit -1\n\
    fi\n\
}\n\
TYPE=$1\n\
SRC=$2\n\
DEST=$(/bin/realpath $3)\n\
validate_dest $DEST\n\
mount -vt "${TYPE}" "${SRC}" "${DEST}"' > /usr/bin/nfsmount \
    && chmod 755 /usr/bin/nfsmount

USER $FSUSER
RUN mkdir $MNTPOINT
WORKDIR /home/$FSUSER
# (&& tail -f /dev/null) tailing /dev/null merely keeps container running... remove when no longer needed
CMD sudo nfsmount $MNTTYPE $FSERVERIP:$FSMNT $MNTPOINT && tail -f /dev/null