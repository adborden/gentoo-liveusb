FROM gentoo/portage:latest as portage

FROM gentoo/stage3:latest
ARG MAKEOPTS="-j9"

COPY  package.use /etc/portage/package.use/local

RUN ( \
  echo "FEATURES=\"buildpkg fail-clean -ipc-sandbox -network-sandbox -pid-sandbox\"" \
  && echo "MAKEOPTS=\"$MAKEOPTS\"" \
  ) >> /etc/portage/make.conf

# TODO Move to sysroot/chroot
RUN ln -snf ../../var/db/repos/gentoo/profiles/default/linux/amd64/17.1 /etc/portage/make.profile


RUN --mount=type=cache,from=portage,source=/var/db/repos/gentoo,target=/var/db/repos/gentoo,ro \
  --mount=type=cache,target=/var/cache/binpkgs \
  --mount=type=tmpfs,target=/var/tmp \
  emerge --buildpkg --usepkg --verbose --quiet \
    sys-block/parted \
    sys-boot/grub \
    sys-fs/dosfstools \
    sys-fs/e2fsprogs

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
