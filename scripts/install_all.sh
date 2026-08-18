#!/bin/sh

cd "$(dirname "$0")"

## Devcontainer mode: minimal setup, nothing desktop-specific ##
if [ "$1" = "devc" ]; then
  ./install_devcontainerdots.sh
  exit 0
fi

sudo -v

## A little directory cleanup just in case 
rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.config/tmux ~/.local/state/nvim/ ~/.local/share/nvim/

## Install Dank or skip ##
if [[ "$1" == "dms" ]]; then
  # install.danklinux.com's bootstrap script doesn't forward args to the
  # dankinstall binary it downloads (it just runs `./installer` with none),
  # so passing flags via `sh -s --` silently gets dropped and it falls back
  # to the interactive TUI. Work around it by patching the fetched script
  # to pass our flags through before running it.
  DANK_BOOTSTRAP=$(mktemp)
  curl -fsSL https://install.danklinux.com -o "$DANK_BOOTSTRAP"
  sed -i 's|^\./installer$|./installer -c hyprland -t ghostty -y --include-deps dms-greeter --danksearch --dankcalendar|' "$DANK_BOOTSTRAP"
  bash "$DANK_BOOTSTRAP"
  rm -f "$DANK_BOOTSTRAP"
fi

## Install pakcages I use ##
if [[ "$1" != "dms" ]]; then
  ./install_ghostty.sh
fi
./install_bitwarden.sh
./install_stow.sh
./install_brew.sh
./install_printer.sh
./install_zsh.sh
./install_vpn.sh
./install_tmux.sh
./install_ufw.sh

## Omarchy overrides ##
if [[ "$1" == "omarchy" ]]; then
  if command -v yay &> /dev/null; then
    yay -S --noconfirm --needed jq
  fi
  if command -v dnf &> /dev/null; then
    sudo dnf install -y jq
  fi

  HYPR_VERSION=$(hyprland --version-json | jq '.version')
  if [[ "$HYPR_VERSION" > "0.55.0" ]]; then
    echo "require(\"omarchy_overrides\")" >> ~/.config/hypr/hyprland.lua
  else
    echo "source = ~/.config/hypr/omarchy_overrides.conf" >> ~/.config/hypr/hyprland.conf
  fi

  #debloat omarchy
  bash <(curl -fsSL https://raw.githubusercontent.com/DanielCoffey1/a-la-carchy/master/a-la-carchy.sh)
fi

## Clone and Stow Dotfiles ##
if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  ./install_dotfiles.sh
fi

