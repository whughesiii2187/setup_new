#!/bin/bash
set -euo pipefail

echo -e "${GREEN}Updating system...${NC}"
sudo pacman -Syu --noconfirm

if [[ "$DESKTOP" == "hypr" ]]; then
  echo -e "${GREEN}Installing official repo packages...${NC}"
  for pkg in "${pacpkg[@]}"; do
      sudo pacman -S --noconfirm --needed "$pkg"
  done
fi

# Install yay (AUR helper)
# Check if aur.archlinux.org is up
echo -e "${GREEN}Checking if aur.archlinux.org is reachable...${NC}"
URL="https://aur.archlinux.org"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
if [ "$STATUS" -eq 200 ]; then
  echo -e "${GREEN}AUR is up. Installing yay from aur.archlinux.org...${NC}"
  source "$ASSETS_DIR"/yay.sh
else
  echo -e "${GREEN}aur.archlinux.org is DOWN. Falling back to GitHub AUR mirror...${NC}"
  source "$ASSETS_DIR"/yay-down.sh
fi

if [ ! -f ~/.zshrc ]; then
  echo -e "${GREEN}.zshrc file not found, not deleting ${NC}"
else
  rm ~/.zshrc
fi

# stow dotfiles
cd "$SCRIPT_DIR"/dotfiles/
mkdir ~/.dotfiles 
if [[ "$DESKTOP" == "hypr" ]]; then
  cp -R .* ~/.dotfiles/
fi
cd ~/.dotfiles

stow .

# Enable services
echo -e "${GREEN}Enabling services...${NC}"
# sudo systemctl enable ly 
sudo systemctl enable greetd
sudo systemctl enable bluetooth.service
sudo systemctl enable power-profiles-daemon.service
sudo systemctl enable NetworkManager.service
sudo systemctl stop systemd-networkd && sudo systemctl disable systemd-networkd
sudo systemctl stop wpa_supplicant && sudo systemctl disable wpa_supplicant
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service pipewire.service 2>/dev/null || true

# Setup Plymouth, snapper snapshots
sudo sed -i 's/\(HOOKS=(.*udev\)/\1 plymouth/' /etc/mkinitcpio.conf
sudo plymouth-set-default-theme optimus
sudo mkinitcpio -P

sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' /etc/snapper/configs/{root,home}
sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' /etc/snapper/configs/{root,home}
sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/{root,home}

# Setup GreetD for autologin
config_block="[initial_session]
command = \"Hyprland\"
user = \"$(whoami)\"
echo "$config_block" >> /etc/greetd/config.toml

# Set Zsh as default shell
if [[ "$SHELL" != "/bin/zsh" ]]; then
  echo -e "${GREEN}Setting Zsh as default shell...${NC}"
  chsh -s "$(which zsh)"
fi

echo -e "${GREEN}✅ Done!! Rebooting system in 30 seconds... ${NC}"
sleep 30s
reboot
