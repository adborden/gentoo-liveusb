#!/bin/bash

sed -i -e "s/MAKEOPTS=/MAKEOPTS=\"$MAKEOPTS\"/" /etc/portage/make.conf

exec "$@"
