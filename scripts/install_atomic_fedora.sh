#!/usr/bin/env bash
#
# Flatpak apps, Homebrew packages, zsh and dotfiles on any Fedora Atomic
# system (Silverblue, Kinoite, COSMIC Atomic, Bluefin, darksaber, ...).
# Every step checks what's already there first: on an image that ships
# something (darksaber ships Flathub, Gear Lever, LibreOffice, Homebrew and
# zsh), that step is skipped; on one that doesn't, it's installed here.
# Nothing here calls rpm-ostree, so no layer is created and no reboot is
# required.
#
# Usage: ./install_atomic_fedora.sh [niri|hypr] [dms|noctalia]
#   Both args are optional. They pick which dotfiles overrides get stowed
#   (see install_dotfiles.sh) and whether the niri-specific steps run.

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

fail_step() {
  echo "!!  $1" >&2
  FAILED_STEPS="$FAILED_STEPS
  - $1"
}

flatpak_install() {
  local attempt
  for attempt in 1 2 3; do
    # --system: Flathub is set up as a system remote (by the image or by
    # setup_flathub below), and a user remote of the same name makes
    # flatpak prompt for which one to use
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

USES_NIRI=false
if [ "$MODE" = "niri" ] || command -v niri &>/dev/null; then
  USES_NIRI=true
fi

## Flathub ##
# Fedora's own images ship only the fedora remote; replace it with Flathub.
# Not install_flatpak.sh: that also applies a global folder-access
# override, which is handled per app in Flatseal instead.
setup_flathub() {
  sudo systemctl disable flatpak-add-fedora-repos.service 2>/dev/null || true
  sudo flatpak remote-delete --system fedora --force 2>/dev/null || true
  sudo flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}
if flatpak remotes --system --columns=name | grep -qx flathub; then
  echo "==> Flathub already set up, skipping"
else
  run_step setup_flathub
fi

## Gear Lever (AppImages) ##
if flatpak info it.mijorus.gearlever &>/dev/null; then
  echo "==> Gear Lever already installed, skipping"
else
  run_step flatpak_install flathub it.mijorus.gearlever
fi

## Homebrew ##
BREW=/home/linuxbrew/.linuxbrew/bin/brew
if [ ! -x "$BREW" ] && systemctl list-unit-files brew-setup.service &>/dev/null; then
  # Images with BlueBuild's brew module (darksaber) unpack Homebrew on
  # first boot; wait for that instead of installing a second copy.
  echo "==> Waiting for the image's brew-setup.service to finish"
  sudo systemctl start brew-setup.service
fi
if [ -x "$BREW" ]; then
  echo "==> Homebrew already installed, skipping its installer"
else
  if ! command -v cc &>/dev/null && ! command -v gcc &>/dev/null; then
    echo "!!  No system compiler found; Homebrew's gcc formula may fail to postinstall" >&2
  fi
  run_step ./install_brew.sh
fi

BREW_PACKAGES=(stow tmux neovim fzf lazygit claude-code font-0xproto-nerd-font gcc clipboard ripgrep tree-sitter-cli devcontainer)
if [ -x "$BREW" ]; then
  eval "$("$BREW" shellenv)"
  run_step brew install "${BREW_PACKAGES[@]}"
else
  fail_step "Homebrew not available; skipped: brew install ${BREW_PACKAGES[*]}"
fi

## zsh as the default shell ##
# Prefer the image's zsh (darksaber ships it) so the login shell never
# depends on Homebrew; otherwise install it with Homebrew.
if [ -x /usr/bin/zsh ]; then
  ZSH_PATH=/usr/bin/zsh
elif command -v brew &>/dev/null && run_step brew install zsh; then
  ZSH_PATH="$(brew --prefix)/bin/zsh"
  grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
else
  ZSH_PATH=""
fi

if [ -n "$ZSH_PATH" ]; then
  if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$ZSH_PATH" ]; then
    echo "==> Login shell is already $ZSH_PATH, skipping"
  else
    run_step sudo chsh -s "$ZSH_PATH" "$USER"
  fi

  if [ -d ~/.oh-my-zsh ]; then
    echo "==> oh-my-zsh already installed, skipping"
  else
    OMZ_INSTALLER="$(mktemp)"
    if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$OMZ_INSTALLER"; then
      bash "$OMZ_INSTALLER" "" --unattended
    else
      fail_step "Failed to download oh-my-zsh installer"
    fi
    rm -f "$OMZ_INSTALLER"
  fi
else
  fail_step "zsh not available, skipping shell change"
fi

## tmux plugin manager ##
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

## Flatpak apps I use ##
# LibreOffice only; install_office.sh also installs OnlyOffice
if flatpak info org.libreoffice.LibreOffice &>/dev/null; then
  echo "==> LibreOffice already installed, skipping"
else
  run_step flatpak_install flathub org.libreoffice.LibreOffice
fi

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
# the whole folder into ~/dotfiles and the compositor's config.kdl and
# DMS's generated dms/*.kdl end up written into the repo.
if [ "$USES_NIRI" = true ]; then
  mkdir -p ~/.config/niri
fi

if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.config/tmux ~/.local/state/nvim/ ~/.local/share/nvim/
  run_step ./install_dotfiles.sh "$MODE" "$SHELL_ARG"
fi

## Niri overrides ##
append_once() {
  grep -qsF "$2" "$1" || echo "$2" >>"$1"
}

if [ "$USES_NIRI" = true ]; then
  if [ -f /usr/share/darksaber/niri/config.kdl ]; then
    # darksaber's config.kdl includes local.kdl last, after DMS's
    # dms/*.kdl, and creates config.kdl itself on first niri login
    NIRI_TARGET=~/.config/niri/local.kdl
  else
    NIRI_TARGET=~/.config/niri/config.kdl
  fi

  if [ "$NIRI_TARGET" = ~/.config/niri/config.kdl ] && [ ! -f "$NIRI_TARGET" ]; then
    # Creating config.kdl here would stop niri from writing its default
    fail_step "$NIRI_TARGET doesn't exist yet; log in to niri once, then rerun this script"
  else
    append_once "$NIRI_TARGET" 'include optional=true "niri_overrides.kdl"'
    if [ "$SHELL_ARG" = "dms" ] || command -v dms &>/dev/null; then
      append_once "$NIRI_TARGET" 'include optional=true "dank_overrides.kdl"'
    fi
  fi

  ## Lid switch ##
  # laptop-display-niri.sh handles lid close/open itself (clamshell when
  # docked, lock when not), so logind must not suspend on its own. Only
  # with niri: on GNOME/KDE variants this would stop lid-close suspend.
  sudo mkdir -p /etc/systemd/logind.conf.d
  sudo tee /etc/systemd/logind.conf.d/no-lid-suspend.conf >/dev/null <<'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
HandleLidSwitchExternalPower=ignore
EOF
fi
