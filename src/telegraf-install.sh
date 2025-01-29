#!/bin/bash -x
export HOME=/tmp
cd /tmp/
sudo -Eu nobody git clone https://aur.archlinux.org/telegraf.git
cd /tmp/telegraf
sudo -Eu nobody makepkg -f
pacman -U --noconfirm *.zst
export HOME=/root
