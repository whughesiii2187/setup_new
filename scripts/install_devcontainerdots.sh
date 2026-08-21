#!/bin/sh

./install_brew.sh
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo "/home/linuxbrew/.linuxbrew/bin/zsh" | sudo tee -a /etc/shells

echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

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
