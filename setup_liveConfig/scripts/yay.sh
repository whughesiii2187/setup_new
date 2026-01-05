#!/bin/bash

if ! command -v yay; then
  if [ ! -d /tmp/yay-bin ]; then
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin
    makepkg -si --noconfirm
  fi
  cd $SCRIPT_DIR
else
  echo -e "${GREEN} Yay is already installed, adding packages!!${NC}"
fi

if [[ "$DESKTOP" == "hypr" ]]; then
  echo -e "${GREEN}Installing AUR packages with yay...${NC}"
  yay -Syu --noconfirm
  for pkg in "${aurpkg[@]}"; do
    yay -S --noconfirm --needed "$pkg"
  done
fi
