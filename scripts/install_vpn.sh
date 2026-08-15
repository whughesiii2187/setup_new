#!/bin/sh

if command -v yay &> /dev/null; then
  yay -S --needed --noconfirm proton-vpn-gtk-app
fi
