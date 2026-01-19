#!/bin/sh

yay -S --noconfirm --needed gazelle-tui networkmanager wpa_supplicant nm-connection-editor wireguard-tools

## Convert from systemd-network and iwd to NetworkManager and wpa_supplicant
sudo systemctl stop iwd systemd-networkd
sudo systemctl disable iwd systemd-networkd

sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

sed -i 's/impala/gazelle/' ~/.local/share/omarchy/bin/omarchy-launch-wifi
