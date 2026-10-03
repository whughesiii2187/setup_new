#!/usr/bin/env bash
#
# Flatpak apps + dotfiles on Fedora Atomic (Silverblue, Kinoite, Cosmic
# Atomic, etc.) — deliberately NOT the native rpm-ostree-layered extras
# (RPM Fusion, codecs, printing, ufw, VPN, Docker). Nothing here calls
# rpm-ostree, so no layer is created and no reboot is required.
#
# The desktop itself is already baked into whichever Atomic image you
# booted — this script never installs a compositor or desktop.
#
# Usage: ./install_atomic_fedora.sh [niri|hypr] [dms|noctalia]
#   Both args are optional and only affect which dotfiles overrides get
#   stowed (see install_dotfiles.sh) — nothing here acts on them otherwise.

cd "$(dirname "$0")"

if [ ! -f /run/ostree-booted ]; then
  echo "Not running on an ostree/bootc system; nothing to do here." >&2
  echo "(Use setup.sh / install_all.sh on a traditional Fedora/Arch install instead.)" >&2
  exit 1
fi

MODE="${1:-}"
SHELL_ARG="${2:-}"

LOG_DIR="$(cd .. && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install-atomic-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "==> Logging to $LOG_FILE"

FAILED_STEPS=""

run_step() {
  echo "==> [$(date '+%H:%M:%S')] $*"
  step_log="$(mktemp)"
  "$@" > >(tee "$step_log") 2>&1
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "!!  [$(date '+%H:%M:%S')] FAILED (exit $status): $*"
    echo "---- last 30 lines of output from this step ----"
    tail -n 30 "$step_log"
    echo "---- end ----"
    FAILED_STEPS="$FAILED_STEPS
  - $* (exit $status)"
  fi
  rm -f "$step_log"
  return "$status"
}

flatpak_install() {
  local attempt
  for attempt in 1 2 3; do
    if flatpak install -y "$@"; then
      return 0
    fi
    if [ "$attempt" -lt 3 ]; then
      echo "flatpak install $* failed (attempt $attempt/3), retrying..." >&2
      sleep 5
    fi
  done
  return 1
}
export -f flatpak_install

print_summary() {
  echo "==> Log saved to $LOG_FILE"
  if [ -n "$FAILED_STEPS" ]; then
    echo "==> Steps that failed:$FAILED_STEPS"
  else
    echo "==> All steps completed successfully"
  fi
}
trap print_summary EXIT

## Flatpak + Flathub + folder access ##
run_step ./install_flatpak.sh

## Homebrew ##
# Covers the CLI tools the traditional path gets from dnf/AUR instead.
# Homebrew's `gcc` formula shells out to a system `cc` in its postinstall —
# Fedora Atomic Desktop images ship gcc already (kernel-devel depends on
# it), so this is expected to just work, but warn instead of hard-failing
# install_brew.sh's `set -e` if some variant doesn't have it.
if ! command -v cc &>/dev/null && ! command -v gcc &>/dev/null; then
  echo "!!  No system compiler found; Homebrew's gcc formula may fail to postinstall" >&2
fi
run_step ./install_brew.sh

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
run_step brew install stow zsh tmux neovim

## zsh as the default shell ##
ZSH_PATH="$(command -v zsh)"
if [ -n "$ZSH_PATH" ]; then
  grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  sudo chsh -s "$ZSH_PATH" "$USER"

  OMZ_INSTALLER="$(mktemp)"
  if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$OMZ_INSTALLER"; then
    bash "$OMZ_INSTALLER" "" --unattended
  else
    echo "!!  Failed to download oh-my-zsh installer" >&2
  fi
  rm -f "$OMZ_INSTALLER"
else
  echo "!!  zsh not found on PATH, skipping shell change" >&2
fi

## tmux plugin manager ##
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

## Flatpak apps I use ##
run_step ./install_zen.sh
run_step ./install_freetube.sh
run_step ./install_office.sh
run_step ./install_qbittorrent.sh
run_step ./install_spotify.sh
run_step ./install_tor.sh
run_step ./install_vlc.sh
run_step ./install_whatsapp.sh
run_step ./install_bitwarden.sh

## Dotfiles ##
if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.config/tmux ~/.local/state/nvim/ ~/.local/share/nvim/
  run_step ./install_dotfiles.sh "$MODE" "$SHELL_ARG"
fi
