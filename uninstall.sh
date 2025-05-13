#!/usr/bin/env bash

set -xuo pipefail

# Kindle Check
if ! { [ -f "/etc/prettyversion.txt" ] && grep -q 'Kindle' /etc/prettyversion.txt; }; then
    echo "Run this on a Kindle" >&2
    exit 1
fi

# Cleanup
kill -9 $(pgrep -f 'nix')
umount /nix
rm -rf /mnt/base-us/system/nix

mntroot rw
rm /etc/upstart/nix-daemon.conf
sed -i '/if \[ -e '"'"'\/nix\/var\/nix\/profiles\/default\/etc\/profile.d\/nix-daemon.sh'"'"' \]; then \. '"'"'\/nix\/var\/nix\/profiles\/default\/etc\/profile.d\/nix-daemon.sh'"'"'; fi/d' /etc/profile
rm -r /etc/nix
rm /bin/nix
rm /bin/nix-build
rm /bin/nix-channel
rm /bin/nix-collect-garbage
rm /bin/nix-copy-closure
rm /bin/nix-daemon
rm /bin/nix-env
rm /bin/nix-hash
rm /bin/nix-instantiate
rm /bin/nix-prefetch-url
rm /bin/nix-shell
rm /bin/nix-store
mntroot ro
