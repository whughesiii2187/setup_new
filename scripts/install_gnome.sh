#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  sudo dnf group install -y "GNOME Desktop"
  sudo systemctl set-default graphical.target
  sudo dnf install -y gnome-tweaks
fi
if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed gnome gdm
  sudo systemctl enable gdm
fi
echo -e "\033[33mConfiguring power settings...\033[0m"
sudo -u $ACTUAL_USER gsettings set org.gnome.desktop.session idle-delay 0 >/dev/null 2>&1
sudo -u $ACTUAL_USER gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' >/dev/null 2>&1
sudo -u $ACTUAL_USER gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' >/dev/null 2>&1
sudo -u $ACTUAL_USER gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0 >/dev/null 2>&1
sudo -u $ACTUAL_USER gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0 >/dev/null 2>&1
sudo -u $ACTUAL_USER gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'suspend' >/dev/null 2>&1

flatpak install -y flathub com.mattjakeman.ExtensionManager >/dev/null 2>&1
