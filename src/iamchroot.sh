#!/bin/sh -e
#
# A simple installer for Artix Linux
#
# Copyright (c) 2022 Maxwell Anderson
#
# This file is part of artix-installer.
#
# artix-installer is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# artix-installer is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with artix-installer. If not, see <https://www.gnu.org/licenses/>.

# Boring stuff you should probably do
ln -sf /usr/share/zoneinfo/"$REGION_CITY" /etc/localtime
hwclock --systohc

# Localization
printf "%s.UTF-8 UTF-8\n" "$LANGCODE" >>/etc/locale.gen
locale-gen
printf "LANG=%s.UTF-8\n" "$LANGCODE" >/etc/locale.conf
printf "KEYMAP=%s\n" "$MY_KEYMAP" >/etc/vconsole.conf

# Host stuff
printf '%s\n' "$MY_HOSTNAME" >/etc/hostname
[ "$MY_INIT" = "openrc" ] && printf 'hostname="%s"\n' "$MY_HOSTNAME" >/etc/conf.d/hostname
printf "\n127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t%s.localdomain\t%s\n" "$MY_HOSTNAME" "$MY_HOSTNAME" >/etc/hosts

# Install boot loader
root_uuid=$(blkid "$PART2" -o value -s UUID)

if [ "$ENCRYPTED" = "y" ]; then
	my_params="cryptdevice=UUID=$root_uuid:root root=\/dev\/mapper\/root"
fi

sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT.*$/GRUB_CMDLINE_LINUX_DEFAULT=\"$my_params\"/g" /etc/default/grub
[ "$ENCRYPTED" = "y" ] && sed -i '/GRUB_ENABLE_CRYPTODISK=y/s/^#//g' /etc/default/grub

grub-install --target=x86_64-efi --efi-directory=/boot --recheck
grub-install --target=x86_64-efi --efi-directory=/boot --removable --recheck
grub-mkconfig -o /boot/grub/grub.cfg

# Maybe other user?
if [ ! -z "$USER" ]; then
        useradd -m -G users,lp,power,video,network,storage,wheel,audio,power,log,optical,scanner,rfkill $USER
	yes "$USER_PASSWORD" | passwd $USER
fi

# Root user
yes "$ROOT_PASSWORD" | passwd

sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers

touch /etc/sudoers.d/10-installer
touch /etc/sudoers.d/ssh_auth_sock
touch /etc/sudoers.d/telegraf

chmod 640 /etc/sudoers.d/10-installer
chmod 640 /etc/sudoers.d/ssh_auth_sock
chmod 640 /etc/sudoers.d/telegraf

echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/10-installer
echo "Defaults>root    env_keep+=SSH_AUTH_SOCK" > /etc/sudoers.d/ssh_auth_sock
echo "telegraf ALL = (root) NOPASSWD: /usr/bin/smartctl" > /etc/sudoers.d/telegraf

# Other stuff you should do
if [ "$MY_INIT" = "openrc" ]; then
	sed -i '/rc_need="localmount"/s/^#//g' /etc/conf.d/swap
	rc-update add connmand default
elif [ "$MY_INIT" = "dinit" ]; then
	ln -s /etc/dinit.d/connmand /etc/dinit.d/boot.d/
fi

# Make vim behave itself
echo "set mouse=" >> /etc/vimrc
echo "set ttymouse=" >> /etc/vimrc

# OpenSSH
rc-update add sshd default
if [ ! -d "/root/.ssh/" ]; then
        mkdir /root/.ssh/
	chmod 700 /root/.ssh/
fi
cp ./authorized_keys /root/.ssh/
chmod 644 /root/.ssh/authorized_keys

# Configure mkinitcpio
[ "$MY_FS" = "btrfs" ] && sed -i 's/BINARIES=()/BINARIES=(\/usr\/bin\/btrfs)/g' /etc/mkinitcpio.conf
if [ "$ENCRYPTED" = "y" ]; then
	sed -i 's/^HOOKS.*$/HOOKS=(base udev autodetect keyboard keymap modconf block encrypt filesystems fsck)/g' /etc/mkinitcpio.conf
else
	sed -i 's/^HOOKS.*$/HOOKS=(base udev autodetect keyboard keymap modconf block filesystems fsck)/g' /etc/mkinitcpio.conf
fi

mkinitcpio -P
