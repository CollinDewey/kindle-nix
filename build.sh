#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#makeself --command bash

set -xeuo pipefail

# Build Nix (Download from Hydra)
nix build nixpkgs#pkgsCross.armv7l-hf-multiplatform.nixVersions.latest --no-link

#
TMP_DIR="$(mktemp -d)"
NIX_FOLDER="$(nix path-info nixpkgs#pkgsCross.armv7l-hf-multiplatform.nixVersions.latest)"
NIX_BASE="$(basename $NIX_FOLDER)"
HEADER="$(nix path-info nixpkgs#makeself)/share/makeself/makeself-header.sh"

# Package
nix-store --query --requisites $NIX_FOLDER | tar -cf "$TMP_DIR/store.tar" -T -
cp -r install.sh nix-daemon.conf nix.conf uninstall.sh $TMP_DIR
echo $NIX_BASE > $TMP_DIR/nix-version.txt
makeself --zstd --header $HEADER --target /mnt/base-us/system/nix-installer $TMP_DIR kindle-nix-installer.sh "Kindle Nix Self-Extract" bash ./install.sh

# Cleanup
rm -rf "$TMP_DIR"