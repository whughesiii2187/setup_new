#!/usr/bin/env bash

if command -v yay &>/dev/null; then
  yay -S --needed --noconfirm ufw
fi

if command -v dnf &>/dev/null; then
  sudo dnf install -y ufw

  if systemctl is-active --quiet firewalld; then
    sudo systemctl disable --now firewalld
  fi
fi

# Allow CUPS through firewall
sudo ufw allow 631/tcp
sudo ufw allow in on virbr0 to any port 67:68 proto udp
sudo sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
