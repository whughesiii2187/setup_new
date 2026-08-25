#!/usr/bin/env bash

cd "$(dirname "$0")"

## Logging: mirror everything to a timestamped file so failures (e.g. a
## step that silently no-ops instead of erroring) are visible after the
## fact, not just on a scrollback the user may not have kept. ##
LOG_DIR="$(cd .. && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
# Keep a handle on the real terminal before we redirect fd1/2 through tee,
# so TUI installers (e.g. dank's) can still get a real TTY further down.
exec 3>&1 4>&2
exec > >(tee -a "$LOG_FILE") 2>&1
echo "==> Logging to $LOG_FILE"

FAILED_STEPS=""

## Run a step, logging its start/end and recording (without aborting the
## rest of the run) whether it failed, since individual steps have always
## been allowed to fail without stopping the overall install. ##
run_step() {
  echo "==> [$(date '+%H:%M:%S')] $*"
  # Also capture this step's own output to a scratch file so that, on
  # failure, we can reprint its tail right here. The full log already has
  # it via the top-level tee, but a long step (e.g. brew installing a
  # dozen formulas) can push the actual error off the top of a small
  # terminal before the FAILED line even appears.
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

## Like run_step, but gives the child a real TTY on stdout/stderr instead
## of the log-file tee pipe. Needed for installers that render a live TUI
## (e.g. dank's bubbletea-based installer), which fail to start when their
## stdout isn't a terminal. This step's output won't land in the log file.
run_step_tty() {
  echo "==> [$(date '+%H:%M:%S')] $*"
  "$@" 1>&3 2>&4
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "!!  [$(date '+%H:%M:%S')] FAILED (exit $status): $*"
    FAILED_STEPS="$FAILED_STEPS
  - $* (exit $status)"
  fi
  return "$status"
}

print_summary() {
  echo "==> Log saved to $LOG_FILE"
  if [ -n "$FAILED_STEPS" ]; then
    echo "==> Steps that failed:$FAILED_STEPS"
  else
    echo "==> All steps completed successfully"
  fi
}
trap print_summary EXIT

## Devcontainer mode: minimal setup, nothing desktop-specific ##
if [ "$1" = "devc" ]; then
  run_step ./install_devcontainerdots.sh
  exit 0
fi

sudo -v

## Install Dank or skip ##
install_dank() {
  # install.danklinux.com's bootstrap script doesn't forward args to the
  # dankinstall binary it downloads (it just runs `./installer` with none),
  # so passing flags via `sh -s --` silently gets dropped and it falls back
  # to the interactive TUI. Work around it by patching the fetched script
  # to pass our flags through before running it.
  DANK_BOOTSTRAP=$(mktemp)
  curl -fsSL https://install.danklinux.com -o "$DANK_BOOTSTRAP"
  sed -i 's|^\./installer$|./installer -c hyprland -t ghostty -y --include-deps dms-greeter --danksearch --dankcalendar|' "$DANK_BOOTSTRAP"
  run_step_tty bash "$DANK_BOOTSTRAP"
  rm -f "$DANK_BOOTSTRAP"
}

install_gnome() {
  sudo dnf group install -y workstation-product
  sudo systemctl enable gdm
}

install_cosmic() {
  sudo dnf group install -y cosmic-desktop cosmic-desktop-apps
}

install_kde() {
  sudo dnf group install -y "KDE Plasma Workspaces"
}

install_omarchy() {
  ## Omarchy overrides ##
  if command -v yay &>/dev/null; then
    yay -S --noconfirm --needed jq
  fi
  if command -v dnf &>/dev/null; then
    sudo dnf install -y jq
  fi

  HYPR_VERSION=$(hyprland --version-json | jq '.version')
  if [[ "$HYPR_VERSION" > "0.55.0" ]]; then
    echo "require(\"omarchy_overrides\")" >>~/.config/hypr/hyprland.lua
  else
    echo "source = ~/.config/hypr/omarchy_overrides.conf" >>~/.config/hypr/hyprland.conf
  fi

  #debloat omarchy
  run_step bash <(curl -fsSL https://raw.githubusercontent.com/DanielCoffey1/a-la-carchy/master/a-la-carchy.sh)
}

case $1 in
dms) install_dank ;;
kde) install_kde ;;
gnome) install_gnome ;;
cosmic) install_cosmic ;;
omarchy) install_omarchy ;;
esac

## Install pakcages I use ##
if [[ "$1" != "dms" ]]; then
  run_step ./install_ghostty.sh
fi
run_step ./install_bitwarden.sh
run_step ./install_stow.sh
run_step ./install_brew.sh
run_step ./install_printer.sh
run_step ./install_zsh.sh
run_step ./install_vpn.sh
run_step ./install_tmux.sh
run_step ./install_ufw.sh

## Clone and Stow Dotfiles ##
if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  # Directory cleanup so stow can symlink cleanly, even if ghostty/nvim/tmux
  # were installed (and their default configs created) by steps above.
  rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.config/tmux ~/.local/state/nvim/ ~/.local/share/nvim/
  run_step ./install_dotfiles.sh
fi
