#!/usr/bin/env bash

## Omarchy overrides ##
if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed jq
fi
if command -v dnf &>/dev/null; then
  sudo dnf install -y jq
fi

HYPR_VERSION=$(hyprland --version-json | jq '.version')
if [[ "$HYPR_VERSION" > "0.55.0" ]]; then
  echo "require(\"omarchy_overrides\")" >>~/.config/hypr/hyprland.lua
else
  echo "source = ~/.config/hypr/omarchy_overrides.conf" >>~/.config/hypr/hyprland.conf
fi

#debloat omarchy
bash <(curl -fsSL https://raw.githubusercontent.com/DanielCoffey1/a-la-carchy/master/a-la-carchy.sh)
