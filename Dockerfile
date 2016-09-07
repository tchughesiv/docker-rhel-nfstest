# docker build --rm -t rhel7/nfstest .
# docker run -tdi --cap-add SYS_ADMIN --device /dev/fuse rhel7/nfstest
### docker run -tdi --cap-add SYS_ADMIN --security-opt seccomp:unconfined --stop-signal=$(kill -l RTMIN+3) --tmpfs /run --tmpfs /run/lock --device /dev/fuse -v /sys/fs/cgroup:/sys/fs/cgroup:ro rhel7/nfstest
### /usr/lib/systemd/systemd --system &
# docker exec {container} ls -la /misc/nfstest/
# mount -v -t nfs 10.1.10.223:/var/export/nfstest /mnt

FROM registry.access.redhat.com/rhel7
MAINTAINER Tommy Hughes <tohughes@redhat.com>

# STOPSIGNAL SIGTERM

RUN set -x \
    && groupadd -r nfsnobody -g 65534 && useradd -u 65534 -r -g nfsnobody -m -s /sbin/nologin -c "Anonymous NFS User" -d /var/lib/nfs nfsnobody \
    && yum -y update \
    && yum -y install autofs iputils nfs-utils fuse \
    && yum clean all \
#     && (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done) \
#     && rm -f /lib/systemd/system/multi-user.target.wants/* \
#     && rm -f /etc/systemd/system/*.wants/* \
#     && rm -f /lib/systemd/system/local-fs.target.wants/* \
#     && rm -f /lib/systemd/system/sockets.target.wants/*udev* \
#     && rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
#     && rm -f /lib/systemd/system/basic.target.wants/* \
#     && rm -f /lib/systemd/system/anaconda.target.wants/* \
#     && setsebool -P virt_use_nfs=true \
#     && systemctl enable autofs
    && mkdir /misc \
    && echo "nfstest     -fstype=nfs,rw,soft,intr,rsize=8192,wsize=8192       10.1.10.223:/var/export/nfstest" >> /etc/auto.misc \
    && sed -i '/automount/d' /etc/nsswitch.conf \
    && echo "automount:  files" >> /etc/nsswitch.conf

## Specify the user which should be used to execute all commands below
# USER nfsnobody
WORKDIR /

## PID 1 conflicts and halt issues
# CMD /bin/bash -c /usr/lib/systemd/systemd --system --unit=multi-user.target

# resolves those issues but nothing watching the process
CMD automount -f