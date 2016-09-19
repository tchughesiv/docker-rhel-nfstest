# docker build --rm -t rhel7/nfstest .
FROM registry.access.redhat.com/rhel7
MAINTAINER Tommy Hughes <tohughes@redhat.com>

ENV FSUSER=nfstest \
    UID_GID=2001 \
    MNTTYPE=nfs

RUN groupadd -r $FSUSER -g $UID_GID && useradd -u $UID_GID -r -g $FSUSER -m -c "$FSUSER User" -d /home/$FSUSER $FSUSER

USER $FSUSER
WORKDIR /home/$FSUSER
# (&& tail -f /dev/null) tailing /dev/null merely keeps container running... remove when no longer needed
CMD tail -f /dev/null
