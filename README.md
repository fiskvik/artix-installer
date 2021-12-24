# artix-installer

A stupid installer for Artix Linux

## Usage

1. Boot into the Artix live disk
2. Acquire the install scripts:
```
yes | sudo pacman -Sy --needed git && \
git clone https://github.com/Zaechus/artix-installer && \
cd artix-installer
```
3. Run `./install.sh`.
4. When everything finishes, `poweroff`, remove the installation media, and boot into Artix.

### Preinstallation

* ISO downloads can be found at [artixlinux.org](https://artixlinux.org/download.php)
* ISO files can be burned to drives with `dd` or something like Etcher.
* `sudo dd bs=4M if=/path/to/artix.iso of=/dev/sd[drive letter] conv=fsync oflag=direct status=progress`
* A better method these days is to use [Ventoy](https://www.ventoy.net/en/index.html)

## Assumptions

* You are already booted into the Artix live disk or you at least have `artools` on your system and have loaded all of the scripts in some way. These scripts can be downloaded with something like `git` or `curl`.
* You want what it wants within certain boundaries.
* You can follow basic instructions.
* You don't mess up. The scripts will only hold your hand so far. Mistakes, of course, will either cause the script to kill itself or render your new system unbootable.
* You know how to use vim as an editor.
* You know what to do when the script drops you into a file to edit or verify. Comments are often dispensed at the bottom of files.
* You're aware that you'll manually have to enter `--type luks1` as a LUKS option until GRUB gets upgraded from 2.0.4
* You're aware that the rEFInd option will probably work but lacks full testing because of issues with QEMU. Submit an issue if it doesn't work.

## What you get

A minimal, encrypted Artix Linux system with OpenRC. Only necessary packages are installed with a few minor exceptions for flavor or the install process (`python`, `zsh`, `neovim`, `neofetch`).

Post-installation networking is done with `connman`.

### Ext4 Partition Scheme
\# | Size | Type | LUKS | FS | Mount
-|-|-|-|-|-
1 | 1G | EFI System |  | fat32 | /boot/efi
2 | FREE | Linux filesystem | * | ext4 | /dev/mapper/cryptroot

#### LVM Volumes
\# | Name | Mount
-|-|-
1 | swap | [SWAP]
2 | root | /

### Btrfs Partition Scheme
\# | Size | Type | LUKS | FS | Mount
-|-|-|-|-|-
1 | 1G | EFI System |  | fat32 | /boot/efi
2 | ~4G | Linux swap | * | swap | [SWAP]
3 | FREE | Linux filesystem | * | btrfs | /dev/mapper/cryptroot

#### Btrfs Subvolumes
\# | Name | Mount
-|-|-
1 | @ | /
2 | @snapshots | /.snapshots
3 | @home | /home

### Software

Options in bold are the preferred stable configuration that is always tested. Options in italics are more difficult to test or are tested less often but will probably work with no issues.

Feature | Name
-|-
Boot loader | _rEFInd_, **GRUB**
Filesystem | ext4, **btrfs**
Init System | OpenRC
Networking | connman
Shell | Zsh
