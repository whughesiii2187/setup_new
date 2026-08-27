#!/usr/bin/env bash

cd "$(dirname "$0")"

LOG_DIR="$(cd .. && pwd)/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
exec 3>&1 4>&2
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
  DANK_BOOTSTRAP=$(mktemp)
  curl -fsSL https://install.danklinux.com -o "$DANK_BOOTSTRAP"
  sed -i 's|^\./installer$|./installer -c hyprland -t ghostty -y --include-deps dms-greeter --danksearch --dankcalendar|' "$DANK_BOOTSTRAP"
  run_step_tty bash "$DANK_BOOTSTRAP"
  rm -f "$DANK_BOOTSTRAP"
}

install_gnome() {
  run_step ./install_gnome.sh
}

install_cosmic() {
  sudo dnf group install -y cosmic-desktop cosmic-desktop-apps
}

install_kde() {
  sudo dnf group install -y "KDE Plasma Workspaces"
}

install_omarchy() {
  run_step ./install_omarchy.sh
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
run_step ./install_docker.sh
run_step ./install_essentials.sh
run_step ./install_firefox.sh
run_step ./install_freetube.sh
run_step ./install_office.sh
run_step ./install_qbittorrent.sh
run_step ./install_spotify.sh
run_step ./install_tor.sh
run_step ./install_vlc.sh
run_step ./install_whatsapp.sh

## Clone and Stow Dotfiles ##
if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  # Directory cleanup so stow can symlink cleanly, even if ghostty/nvim/tmux
  # were installed (and their default configs created) by steps above.
  rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.config/tmux ~/.local/state/nvim/ ~/.local/share/nvim/
  run_step ./install_dotfiles.sh
fi
