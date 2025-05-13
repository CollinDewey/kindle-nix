#!/usr/bin/env bash

set -xeuo pipefail

# Kindle Check
if ! { [ -f "/etc/prettyversion.txt" ] && grep -q 'Kindle' /etc/prettyversion.txt; }; then
    echo "Run this on a Kindle" >&2
    exit 1
fi

# Create store
# Since this is backed by FAT32, we're "stuck" with 4GB
mkdir -p /mnt/base-us/system/nix
fallocate -l 4095M /mnt/base-us/system/nix/nix.ext4
mkfs.ext4 /mnt/base-us/system/nix/nix.ext4

# Create Nix store and copy Nix
mntroot rw
mkdir -p /nix
mount -o loop -t ext4 /mnt/base-us/system/nix/nix.ext4 /nix
install -dv -m 0755 /nix /nix/var /nix/var/log /nix/var/log/nix /nix/var/log/nix/drvs /nix/var/nix{,/db,/gcroots,/profiles,/temproots,/userpool,/daemon-socket} /nix/var/nix/{gcroots,profiles}/per-user
install -dv -m 0555 /etc/nix
install -dv -m 1775 /nix/store
tar -xf ./store.tar -C /

# Copy daemon upstart and nix config
cp ./nix-daemon.conf /etc/upstart/nix-daemon.conf
cp ./nix.conf /etc/nix/nix.conf
echo "if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; fi" >> /etc/profile

# Link to /bin
VERSION=$(cat nix-version.txt)
ln -sf /nix/store/$VERSION/bin/nix /bin/nix
ln -sf /bin/nix /bin/nix-build
ln -sf /bin/nix /bin/nix-channel
ln -sf /bin/nix /bin/nix-collect-garbage
ln -sf /bin/nix /bin/nix-copy-closure
ln -sf /bin/nix /bin/nix-daemon
ln -sf /bin/nix /bin/nix-env
ln -sf /bin/nix /bin/nix-hash
ln -sf /bin/nix /bin/nix-instantiate
ln -sf /bin/nix /bin/nix-prefetch-url
ln -sf /bin/nix /bin/nix-shell
ln -sf /bin/nix /bin/nix-store

# RO Root
mntroot ro

/bin/nix-env -i /nix/store/$VERSION