#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  sudo dnf group install -y "GNOME Desktop"
  sudo systemctl set-default graphical.target
  sudo dnf install -y gnome-tweaks flatpak
fi
if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed gnome gdm flatpak
  sudo systemctl enable gdm
fi
echo -e "\033[33mConfiguring power settings...\033[0m"
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'suspend'

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.mattjakeman.ExtensionManager
