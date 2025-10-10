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
rm /bin/nix*
mntroot ro
