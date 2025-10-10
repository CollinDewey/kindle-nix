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

# Create Nix store
mntroot rw
mkdir -p /nix
mount -o loop -t ext4 /mnt/base-us/system/nix/nix.ext4 /nix
install -dv -m 0755 /nix /nix/var /nix/var/log /nix/var/log/nix /nix/var/log/nix/drvs /nix/var/nix{,/db,/gcroots,/profiles,/temproots,/userpool,/daemon-socket} /nix/var/nix/{gcroots,profiles}/per-user
install -dv -m 0555 /etc/nix
install -dv -m 1775 /nix/store

# Download and extract Nix
# Didn't see a great way to get the latest tag
TAGS=$(curl -s "https://api.github.com/repos/nixos/nix/tags" | awk -F'"' '/name/{print $4}')
TAG=$(echo "$TAGS" | head -n 1)
URL=https://releases.nixos.org/nix/nix-$TAG/nix-$TAG-armv7l-linux.tar.xz
curl -L "$URL" | tar -xJ -C '/nix/store' --strip-components=2

# Create nix-daemon upstart config
cat > /etc/upstart/nix-daemon.conf << 'EOF'
__NIX_DAEMON_CONF__
EOF

# Create nix config
cat > /etc/nix/nix.conf << 'EOF'
__NIX_CONF__
EOF

# Create uninstall script
cat > /mnt/base-us/system/nix/uninstall.sh << 'EOF'
__NIX_UNINSTALL__
EOF

echo "if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; fi" >> /etc/profile

# Link to /bin
ln -s /nix/store/*-nix-armv7l-*/bin/nix /bin/
cp -a /nix/store/*-nix-armv7l-*/bin/nix-* /bin/

# RO Root
mntroot ro

/bin/nix profile add /nix/store/*-nix-armv7l-*/