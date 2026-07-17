#!/bin/sh
sudo systemctl disable --now avahi-daemon

if command -v yay &> /dev/null; then 
  yay -S --needed --noconfirm hplip cups system-config-printer
fi

if command -v dnf &> /dev/null; then
  sudo dnf install -y hplip cups system-config-printer
fi

sudo systemctl enable --now cups && sudo systemctl start cups
