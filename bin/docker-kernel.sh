#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

# Install genkernel
USE=symlink emerge --usepkg --quiet --update --verbose genkernel gentoo-sources
genkernel --kernel-config=kernel/5.15.85.config.txt --minkernpackage=kernel.tar.xz --modulespackage=modules.tar.xz --no-clean --no-install all
