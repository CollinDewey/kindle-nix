# kindle-nix
Install Nix on your Kindle (The e-paper kind)

You need a jailbroken Kindle.

## Usage
Go to the releases page and run kindle-nix-installer.sh on your Kindle

Build and transfer applications over via
```
nix build nixpkgs#pkgsCross.armv7l-hf-multiplatform.htop
nix-copy-closure --to root@KINDLE_IP $(nix path-info nixpkgs#pkgsCross.armv7l-hf-multiplatform.htop)
ssh root@KINDLE_IP "nix-env -i $(nix path-info nixpkgs#pkgsCross.armv7l-hf-multiplatform.htop)"
```

If you just want it to be easy, you can set a shell alias to run this all for you.
```
alias kindle-send='f(){ p=nixpkgs#pkgsCross.armv7l-hf-multiplatform.$2 && nix build $p && for c in $(nix path-info $p); do nix-copy-closure --to $1 $c && ssh $1 "nix-env -i $c"; done; }; f'
```
Which you execute like
```
kindle-send root@IP htop
```

You can build applications on the kindle itself, but it'll likely run out of memory. Nix is hungry. Yummy RAM.

## How it works

The Kindle has some space for user storage, which is FAT32 formatted. This mount is mounted with noexec. While it can be remounted to not have noexec, there are still features missing from FAT32, such as symlinks. So this script creates a 4GB file (FAT32 max) and puts an EXT4 filesystem in the file, mounting it as a loop device to /nix. This gives us all the filesystem features we need.

The installer is packed with makeself, making it easy to just run a script and get Nix up and running. First we cross compile the latest version Nix and put all of the files together in an archive. Then the few config files, such as for setting up automount for /nix. Shove all the files into the right spots and we're set.

## kterm

If you're using kterm, it may not source /etc/profile. Just run `. /etc/profile` in your terminal.

## Uninstall
```
bash /mnt/base-us/system/nix-installer/uninstall.sh
```