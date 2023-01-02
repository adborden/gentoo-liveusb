#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

# Build sysroot
# Work around bug postinstall for mail-mta/nullmailer user nullmail:nullmail does not exist
emerge --quiet --oneshot mail-mta/nullmailer

# Install world packages, read packages from stdin
xargs emerge --usepkg --quiet --update --verbose --keep-going
