#!/usr/bin/env bash

cd "$(dirname "$0")"

./install_brew.sh "$1"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo "/home/linuxbrew/.linuxbrew/bin/zsh" | sudo tee -a /etc/shells

echo "Installing oh-my-zsh"
OMZ_INSTALLER="$(mktemp)"
if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$OMZ_INSTALLER"; then
  bash "$OMZ_INSTALLER" "" --unattended
else
  echo "!!  Failed to download oh-my-zsh installer" >&2
fi
rm -f "$OMZ_INSTALLER"

git clone --filter=blob:none --sparse https://github.com/whughesiii2187/dotfiles ~/dotfiles
cd ~/dotfiles/
git sparse-checkout set nvim tmux-devc zshrc-devc

stow -t ~ nvim
stow -t ~ tmux-devc

if [ -f "$HOME/.zshrc" ]; then
  echo "source $HOME/dotfiles/zshrc-devc/.zshrc" >>"$HOME/.zshrc"
else
  stow -t ~ zshrc-devc
fi
