#!/usr/bin/env bash
#
# Personal Flatpak apps, Homebrew packages and dotfiles on top of the
# darksaber image. The image already provides the desktop, codecs,
# printing, ufw, virtualization, Flathub, Gear Lever, LibreOffice, Homebrew
# and zsh, so none of that is repeated here. Nothing here calls
# rpm-ostree, so no layer is created and no reboot is required.
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
    # --system: darksaber ships Flathub as a system remote, and a user
    # remote of the same name makes flatpak prompt for which one to use
    if flatpak install --system -y "$@"; then
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
trap 'FAILED_STEPS="$FAILED_STEPS
  - interrupted"; exit 130' INT

## Homebrew packages ##
# Flathub, Gear Lever, Homebrew itself and a system gcc all come with the
# darksaber image, so only the packages are installed here. Homebrew is set
# up by brew-setup.service on first boot.
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  run_step brew install stow tmux neovim lazygit claude-code font-0xproto-nerd-font gcc clipboard ripgrep tree-sitter-cli devcontainer
else
  echo "!!  Homebrew isn't set up yet (brew-setup.service runs on first boot); rerun this script later" >&2
  FAILED_STEPS="$FAILED_STEPS
  - brew install (Homebrew not set up yet)"
fi

## zsh as the default shell ##
# Fedora's zsh from the image, so the login shell never depends on Homebrew.
ZSH_PATH=/usr/bin/zsh
if [ -x "$ZSH_PATH" ]; then
  sudo chsh -s "$ZSH_PATH" "$USER"

  OMZ_INSTALLER="$(mktemp)"
  if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$OMZ_INSTALLER"; then
    bash "$OMZ_INSTALLER" "" --unattended
  else
    echo "!!  Failed to download oh-my-zsh installer" >&2
  fi
  rm -f "$OMZ_INSTALLER"
else
  echo "!!  $ZSH_PATH not found, skipping shell change" >&2
fi

## tmux plugin manager ##
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

## Flatpak apps I use ##
run_step ./install_zen.sh
run_step ./install_freetube.sh
run_step ./install_qbittorrent.sh
run_step ./install_spotify.sh
run_step ./install_tor.sh
run_step ./install_vlc.sh
run_step ./install_whatsapp.sh
run_step ./install_bitwarden.sh

## Dotfiles ##
# Make sure ~/.config/niri is a real directory first, otherwise stow links
# the whole folder into ~/dotfiles and darksaber's config.kdl and DMS's
# generated dms/*.kdl end up written into the repo.
mkdir -p ~/.config/niri

if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.config/tmux ~/.local/state/nvim/ ~/.local/share/nvim/
  run_step ./install_dotfiles.sh "$MODE" "$SHELL_ARG"
fi

## Niri overrides ##
# darksaber's config.kdl includes local.kdl last, after DMS's dms/*.kdl,
# so the overrides go there instead of into config.kdl (which darksaber
# creates on first niri login).
LOCAL_KDL=~/.config/niri/local.kdl
for f in niri_overrides.kdl dank_overrides.kdl; do
  grep -qsF "\"$f\"" "$LOCAL_KDL" || echo "include optional=true \"$f\"" >>"$LOCAL_KDL"
done

## Lid switch ##
# laptop-display-niri.sh handles lid close/open itself (clamshell when
# docked, lock when not), so logind must not suspend on its own.
sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/no-lid-suspend.conf >/dev/null <<'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
HandleLidSwitchExternalPower=ignore
EOF
