# gentoo-liveusb

Create liveUSB environments based on Gentoo Linux.

## Notes

genkernel --firmware --bootdir=/tmp/boot --no-symlink --all-ramdisk-modules --install all

https://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds/current-stage3-amd64-desktop-systemd/
https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/current-stage3-amd64-desktop-systemd/


https://mirrors.163.com/gentoo/snapshots/gentoo-latest.tar.xz


## Testing

EFI boot

    sudo qemu-system-x86_64  --bios /usr/share/edk2-ovmf/OVMF_CODE.fd -net none -drive format=raw,file=gentoo-liveusb.iso -serial stdio -m 4G

## TODO

- [ ] sfdisk script to create partition table
- [ ] add dm-verity to root partition
- [ ] auto-expand rw partition
