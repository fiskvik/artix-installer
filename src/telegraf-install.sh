#!/bin/bash -x
export HOME=/tmp
cd /tmp/
sudo -Eu nobody git clone https://aur.archlinux.org/telegraf.git
cd /tmp/telegraf
sudo -Eu nobody makepkg -f
pacman -U --noconfirm *.zst
useradd --system --home-dir /var/lib/telegraf --shell=/usr/bin/nologin telegraf
export HOME=/root
