#!/bin/bash
set -e

if [ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  # Fetch to a file and check curl's own exit status first: piping a failed
  # curl straight into `bash -c "$(...)"` silently becomes `bash -c ""`,
  # which "succeeds" while doing nothing, masking the real failure.
  BREW_INSTALLER="$(mktemp)"
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$BREW_INSTALLER"
  /bin/bash "$BREW_INSTALLER"
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

brew install neovim fzf lazygit zsh tmux claude-code font-0xproto-nerd-font gcc clipboard ripgrep tree-sitter-cli stow devcontainer
