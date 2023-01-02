#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -x


iso_image_output=$1
rootfs_tarball=$2
kernel_tarball=$3
modules_tarball=$4

iso_image=${iso_image_output}.tmp

function cleanup () {
  umount ${workdir}/boot
  umount ${workdir}/efi
  losetup -D
  rm -rf $iso_image
}

function get_partition_offset () {
  image=$1
  partition=$2

  parted --script --machine $image 'unit b print' | grep "^${partition}" | cut -d: -f2 | tr -d B
}

function get_partition_size () {
  image=$1
  partition=$2

  parted --script --machine $image 'unit b print' | grep "^${partition}" | cut -d: -f4 | tr -d B
}

function setup_partition_loop_device () {
  local image offset partition size
  image=$1
  partition=$2

  offset=$(get_partition_offset $image $partition)
  size=$(get_partition_size $image $partition)

  losetup --show --offset $offset --sizelimit $size --find $iso_image
}


trap cleanup EXIT

truncate --size 4352M ${iso_image}

parted --align optimal --script $iso_image mklabel gpt
parted --align optimal --script $iso_image unit mib mkpart efi 1 64
parted --align optimal --script $iso_image unit mib mkpart boot 64 128
parted --align optimal --script $iso_image unit mib mkpart root 128 4224
parted --align optimal --script $iso_image unit mib mkpart rw 4224 4288

# Setup workspace
workdir=$(mktemp --directory --tmpdir=$(pwd))
boot_dir=${workdir}/boot
efi_dir=${workdir}/efi
mountpoint=${workdir}/mnt
mkdir --parents ${boot_dir} ${efi_dir} ${mountpoint}

# Install bootloader
loop_device=$(losetup --show --find $iso_image)
efi_device=$(setup_partition_loop_device $iso_image 1)
mkfs.vfat -n EFI $efi_device
boot_device=$(setup_partition_loop_device $iso_image 2)
mkfs.ext2 -L boot $boot_device

mount $boot_device ${workdir}/boot
mount $efi_device ${workdir}/efi

tar xvf ${kernel_tarball} --directory ${workdir}/boot
grub-install --removable --boot-directory=${workdir}/boot --efi-directory=${workdir}/efi --target=x86_64-efi ${loop_device}
GRUB_DISABLE_OS_PROBER=true GRUB_PREFIX=/boot/grub grub-mkconfig -o ${workdir}/boot/grub/grub.cfg

umount ${workdir}/boot
umount ${workdir}/efi
losetup --detach ${loop_device}
losetup --detach $efi_device
losetup --detach $boot_device

# root partition
loop_device=$(setup_partition_loop_device $iso_image 3)
mkfs.ext4 -L root ${loop_device}
mount ${loop_device} ${mountpoint}
tar xpvf ${rootfs_tarball} --xattrs-include='*.*' --numeric-owner --directory ${mountpoint}
tar xvf ${modules_tarball} --directory ${mountpoint}
umount ${mountpoint}
losetup --detach ${loop_device}

mv ${iso_image} ${iso_image_output}

rm -rf ${workdir}
