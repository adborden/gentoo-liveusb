.PHONY: buildroot kernel rootfs sign

all: image

kernel: kernel.tar.xz
kernel.tar.xz modules.tar.xz: kernel/5.15.85.config.txt
	bash bin/docker-kernel.sh

buildroot: .stamp-buildroot
.stamp-buildroot: world_packages
	bash bin/docker-build-sysroot.sh < $<
	touch $@

rootfs: rootfs.tar.xz
rootfs.tar.xz: .stamp-buildroot
	bash bin/docker-rootfs.sh

image: gentoo-liveusb.iso
gentoo-liveusb.iso: rootfs.tar.xz kernel.tar.xz modules.tar.xz
	bash bin/build-image.sh $@ $^

sign: gentoo-liveusb.iso.asc
gentoo-liveusb.iso.asc: gentoo-liveusb.iso
	gpg --detatch-sign --armor $<
