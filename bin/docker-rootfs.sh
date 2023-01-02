#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -x

rootfs_dir=rootfs
mkdir -p $rootfs_dir

function cleanup () {
  rm -rf $rootfs_dir
}

trap cleanup EXIT

mkdir --parents $rootfs_dir/{dev,home,media,mnt,opt,proc,sys,run}
mkdir --parents --mode 0700 $rootfs_dir/root
mkdir --parents --mode 1777 $rootfs_dir/tmp
mknod -m 600 ${rootfs_dir}/dev/console c 5 1
mknod -m 666 ${rootfs_dir}/dev/null c 1 3
mknod -m 666 ${rootfs_dir}/dev/tty c 5 0
mknod -m 660 ${rootfs_dir}/dev/loop0 b 7 0
mknod -m 666 ${rootfs_dir}/dev/random c 1 8
mknod -m 666 ${rootfs_dir}/dev/urandom c 1 9
mknod -m 600 ${rootfs_dir}/dev/ttyS0 c 4 64
mknod -m 620 ${rootfs_dir}/dev/tty1 c 4 1
mknod -m 620 ${rootfs_dir}/dev/tty2 c 4 2
mknod -m 620 ${rootfs_dir}/dev/tty3 c 4 3
mknod -m 620 ${rootfs_dir}/dev/tty4 c 4 4
mknod -m 620 ${rootfs_dir}/dev/tty5 c 4 5
mknod -m 620 ${rootfs_dir}/dev/tty6 c 4 6
mknod -m 620 ${rootfs_dir}/dev/tty7 c 4 7
mknod -m 620 ${rootfs_dir}/dev/tty8 c 4 8
mknod -m 620 ${rootfs_dir}/dev/tty9 c 4 9
mknod -m 620 ${rootfs_dir}/dev/tty10 c 4 10
mknod -m 620 ${rootfs_dir}/dev/tty11 c 4 11
mknod -m 620 ${rootfs_dir}/dev/tty12 c 4 12
chown root:tty ${rootfs_dir}/dev/tty*

# TODO use --usepkgonly?
xargs emerge --root=$rootfs_dir --usepkg --quiet --update --verbose --jobs=4 < world_packages

tar cpv --xattrs --acls --directory ${rootfs_dir} . | xz --compress --threads=0 > rootfs.tar.xz
