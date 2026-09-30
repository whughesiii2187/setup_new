#!/usr/bin/env bash

# native fallback, disabled in favor of flatpak — see install_flatpak.sh
# if command -v yay &>/dev/null; then
#   yay -S --noconfirm --needed bitwarden
# fi
#
# if command -v dnf &>/dev/null; then
#   sudo dnf install -y snap
#   sudo snap wait system seed.loaded
#   sudo snap install bitwarden
# fi

flatpak_install flathub com.bitwarden.desktop

# Bitwarden's SSH agent creates a socket that the (sandboxed) app and
# (unsandboxed) ssh/git both need to agree on the path to. Point both sides
# at a path inside Bitwarden's own Flatpak data dir, which it can already
# write to without any extra `flatpak override`. environment.d is
# shell-agnostic (picked up by systemd --user for terminals and GUI apps
# alike), so this doesn't need to touch the external dotfiles repo's zshrc.
mkdir -p ~/.config/environment.d
cat >~/.config/environment.d/bitwarden-ssh-agent.conf <<'EOF'
BITWARDEN_SSH_AUTH_SOCK=%h/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock
SSH_AUTH_SOCK=%h/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock
EOF

echo -e "\033[33mBitwarden installed — enable \"SSH agent\" in Bitwarden's own Settings to finish SSH agent setup (can't be scripted).\033[0m"
