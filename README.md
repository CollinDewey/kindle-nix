# kindle-nix
Install Nix on your Kindle (The e-paper kind)

You need a jailbroken Kindle.

## Usage
Go to the releases page and run kindle-nix-installer.sh on your Kindle

```
curl -fsSLO https://github.com/CollinDewey/kindle-nix/releases/latest/download/kindle-nix-installer.sh
bash kindle-nix-installer.sh
rm kindle-nix-installer.sh
```

Build and transfer applications over via building it on a more powerful computer and moving over the closure, then "installing" it with nix profile/nix-env
```
nix build nixpkgs#pkgsCross.armv7l-hf-multiplatform.htop
nix copy --to ssh://root@KINDLE_IP $(nix path-info nixpkgs#pkgsCross.armv7l-hf-multiplatform.htop)
ssh root@KINDLE_IP "nix profile add $(nix path-info nixpkgs#pkgsCross.armv7l-hf-multiplatform.htop)"
```

Here's a shell alias to simplify pushing applications to the Kindle
```
alias kindle-send='f(){ p=nixpkgs#pkgsCross.armv7l-hf-multiplatform.$2 && for c in $(nix build $p --no-link --print-out-paths); do nix copy --to ssh://$1 $c && ssh $1 "nix profile add $c"; done; }; f'
```
Which you run like
```
kindle-send root@<IP> htop
```

Building applications on the Kindle itself will result in it running out of free RAM.

## How it works

The Kindle has some space for user storage, which is FAT32 formatted. This mount is mounted with noexec. While it can be remounted to not have noexec, there are still features missing from FAT32, such as symlinks. So this script creates a 4GB file (FAT32 max) and puts an EXT4 filesystem in the file, mounting it as a loop device to /nix. This gives us all the filesystem features we need.

The installer then downloads the latest Nix version from the internet and places the needed configuration changes into the system. See more about that on my [article](https://collindewey.net/articles/nix-on-kindle/) about this project.

## kterm

If you're using kterm, it may not source /etc/profile. Just run `. /etc/profile` in your terminal.

## Uninstall
```
bash /mnt/base-us/system/nix/uninstall.sh
```