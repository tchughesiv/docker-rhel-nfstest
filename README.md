# docker-rhel-nfstest
docker build --rm -t rhel7/automount-nfs automount-nfs/

docker build --rm -t rhel7/sshfs-fuse sshfs-fuse/

docker build --rm -t rhel7/nfsmount nfsmount/

docker run -tdi --cap-add SYS_ADMIN rhel7/automount-nfs

docker run -tdi --cap-add SYS_ADMIN --device /dev/fuse rhel7/sshfs-fuse

docker run -tdi --cap-add SYS_ADMIN rhel7/nfsmount
