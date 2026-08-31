#!/usr/bin/env bash
set -e

# Homebrew's gcc formula runs a postinstall step that shells out to the
# system `cc`; without a system compiler present that step fails and takes
# the whole `brew install` (and this script, under set -e) down with it.
if command -v dnf &>/dev/null; then
  sudo dnf install -y gcc gcc-c++ make
elif command -v yay &>/dev/null; then
  yay -S --noconfirm --needed base-devel
fi

if [ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  # Fetch to a file and check curl's own exit status first: piping a failed
  # curl straight into `bash -c "$(...)"` silently becomes `bash -c ""`,
  # which "succeeds" while doing nothing, masking the real failure.
  BREW_INSTALLER="$(mktemp)"
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$BREW_INSTALLER"
  NONINTERACTIVE=1 /bin/bash "$BREW_INSTALLER"
  rm -f "$BREW_INSTALLER"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# `brew update` is what triggers Homebrew's own portable-ruby fetch from
# ghcr.io. That fetch has been seen to fail transiently (e.g. a GitHub
# rate-limit hit right after another GitHub-hosted download, like the dank
# installer step in install_all.sh) and succeed on a bare rerun, so retry
# with backoff instead of failing the whole install over it.
attempt=1
until brew update; do
  if [ "$attempt" -ge 3 ]; then
    echo "brew update failed after $attempt attempts" >&2
    exit 1
  fi
  echo "brew update failed (attempt $attempt), retrying in $((attempt * 5))s..." >&2
  sleep "$((attempt * 5))"
  attempt=$((attempt + 1))
done

if [ "$1" = "devc" ]; then
  brew install neovim fzf lazygit zsh tmux claude-code font-0xproto-nerd-font gcc clipboard ripgrep tree-sitter-cli stow devcontainer
else
  # neovim, zsh, tmux, and stow are installed by their own install_*.sh scripts instead.
  brew install fzf lazygit claude-code font-0xproto-nerd-font gcc clipboard ripgrep tree-sitter-cli
fi
