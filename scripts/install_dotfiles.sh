#!/usr/bin/env bash
#
# Clone and stow the dotfiles, plus the per-user setup they depend on:
# oh-my-zsh, TPM, Bitwarden's SSH agent, the Niri override includes and
# the lid switch. On darksaber, where the image ships every package, this
# is the only script to run. Safe to rerun: each step checks first.
#
# Usage: ./install_dotfiles.sh [niri|hypr] [dms|noctalia]
#   When left out, they're detected from what's installed.

cd "$(dirname "$0")"

MODE="${1:-}"
SHELL_ARG="${2:-}"
if [ -z "$MODE" ] && command -v niri &>/dev/null; then
  MODE=niri
fi
if [ -z "$SHELL_ARG" ] && command -v dms &>/dev/null; then
  SHELL_ARG=dms
fi

failed=0
fail() {
  echo "!!  $1" >&2
  failed=1
}

## oh-my-zsh and TPM ##
# Before stowing: the oh-my-zsh installer writes its own ~/.zshrc
if [ -d ~/.oh-my-zsh ]; then
  echo "oh-my-zsh already installed, skipping"
else
  OMZ_INSTALLER="$(mktemp)"
  if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$OMZ_INSTALLER"; then
    bash "$OMZ_INSTALLER" "" --unattended || fail "oh-my-zsh installer failed"
  else
    fail "Failed to download oh-my-zsh installer"
  fi
  rm -f "$OMZ_INSTALLER"
fi

if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || fail "Failed to clone TPM"
fi

## Dotfiles ##
if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  # Make sure ~/.config/niri is a real directory first, otherwise stow links
  # the whole folder into ~/dotfiles and the compositor's config.kdl and
  # DMS's generated dms/*.kdl end up written into the repo.
  if [ "$MODE" = "niri" ]; then
    mkdir -p ~/.config/niri
  fi

  # Remove default configs so stow can symlink cleanly
  rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.config/tmux ~/.local/state/nvim/ ~/.local/share/nvim/

  git clone --filter=blob:none --sparse https://github.com/whughesiii2187/dotfiles ~/dotfiles || {
    fail "Failed to clone dotfiles"
    exit 1
  }
  (
    cd ~/dotfiles/ || exit 1
    git sparse-checkout set dank ghostty tmux zshrc nvim aerospace sketchybar zshrc-mac scripts wireplumber hypr niri

    stow -t ~ ghostty
    stow -t ~ nvim
    stow -t ~ tmux
    stow -t ~ wireplumber
    stow -t ~ scripts

    if [ "$SHELL_ARG" = "dms" ]; then
      stow -t ~ dank
    fi

    if [ "$MODE" = "niri" ]; then
      stow -t ~ niri
    elif [ "$MODE" = "hypr" ]; then
      stow -t ~ hypr
    fi

    rm -f "$HOME/.zshrc"
    stow -t ~ zshrc

    # OS Specific
    if [ "$(uname)" = "Darwin" ]; then
      stow -t ~ aerospace
      stow -t ~ sketchybar
      stow -t ~ zshrc-mac
    fi
  ) || fail "Stowing dotfiles failed"
fi

## Bitwarden SSH agent ##
if [ "$(uname)" != "Darwin" ]; then
  if flatpak info com.bitwarden.desktop &>/dev/null; then
    ./setup_bitwarden_ssh.sh
  else
    # darksaber installs it on first boot; it may still be downloading
    fail "Bitwarden isn't installed (yet); rerun this script once it is to set up its SSH agent"
  fi
fi

## Niri overrides ##
append_once() {
  grep -qsF "$2" "$1" || echo "$2" >>"$1"
}

if [ "$MODE" = "niri" ]; then
  if [ -f /usr/share/darksaber/niri/config.kdl ]; then
    # darksaber's config.kdl includes local.kdl last, after DMS's
    # dms/*.kdl, and creates config.kdl itself on first niri login
    NIRI_TARGET=~/.config/niri/local.kdl
  else
    NIRI_TARGET=~/.config/niri/config.kdl
  fi

  if [ "$NIRI_TARGET" = ~/.config/niri/config.kdl ] && [ ! -f "$NIRI_TARGET" ]; then
    # Creating config.kdl here would stop niri from writing its default
    fail "$NIRI_TARGET doesn't exist yet; log in to niri once, then rerun this script"
  else
    append_once "$NIRI_TARGET" 'include optional=true "niri_overrides.kdl"'
    if [ "$SHELL_ARG" = "dms" ]; then
      append_once "$NIRI_TARGET" 'include optional=true "dank_overrides.kdl"'
    fi
  fi

  ## Lid switch ##
  # The dotfiles' laptop-display script handles lid close/open itself
  # (clamshell when docked, lock when not), so logind must not suspend on
  # its own. Only with niri (on GNOME/KDE this would stop lid-close
  # suspend), and only when the script is actually there: otherwise
  # closing the lid would do nothing at all.
  if compgen -G "$HOME/.config/niri/scripts/laptop-display*.sh" >/dev/null; then
    sudo mkdir -p /etc/systemd/logind.conf.d
    sudo tee /etc/systemd/logind.conf.d/no-lid-suspend.conf >/dev/null <<'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
HandleLidSwitchExternalPower=ignore
EOF
  else
    sudo rm -f /etc/systemd/logind.conf.d/no-lid-suspend.conf
    fail "No laptop-display script in ~/.config/niri/scripts; leaving logind's lid-close suspend on"
  fi
fi

exit "$failed"
