#!/bin/sh

if command -v yay &> /dev/null; then
  yay -S --needed --noconfirm omarchy-vpn
fi
