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
  if command -v script &>/dev/null; then
    # A plain pipe/tee here would turn stdout into a non-tty, which breaks
    # installers (like Dank's) that rely on isatty() for prompts/spinners.
    # `script` allocates a real pty for the child so it stays interactive,
    # while still recording the session to $LOG_FILE.
    local cmd
    printf -v cmd '%q ' "$@"
    script --quiet --append --return --flush --command "$cmd" "$LOG_FILE" 1>&3 2>&4
  else
    "$@" 1>&3 2>&4
  fi
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "!!  [$(date '+%H:%M:%S')] FAILED (exit $status): $*"
    FAILED_STEPS="$FAILED_STEPS
  - $* (exit $status)"
  fi
  return "$status"
}

flatpak_install() {
  local attempt
  for attempt in 1 2 3; do
    # --system: install_flatpak.sh adds Flathub as a system remote, and a
    # user remote of the same name makes flatpak prompt for which one to use
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

## Devcontainer mode: minimal setup, nothing desktop-specific ##
if [ "$1" = "devc" ]; then
  run_step ./install_devcontainerdots.sh "$1"
  exit 0
fi

# MODE is a compositor (hypr/niri) or a standalone desktop mode
# (gnome/kde/cosmic). SHELL_ARG is only meaningful alongside a
# compositor: dms or noctalia.
MODE="$1"
SHELL_ARG="${2:-}"

case "$MODE" in
hypr) COMPOSITOR="hyprland" ;;
niri) COMPOSITOR="niri" ;;
esac

sudo -v

## Install Dank ##
install_dank() {
  local compositor="${1:-hyprland}"
  DANK_BOOTSTRAP=$(mktemp)
  if ! curl -fsSL https://install.danklinux.com -o "$DANK_BOOTSTRAP"; then
    echo "!!  [$(date '+%H:%M:%S')] FAILED to download Dank bootstrap script"
    FAILED_STEPS="$FAILED_STEPS
  - install_dank: curl https://install.danklinux.com (download failed)"
    rm -f "$DANK_BOOTSTRAP"
    return 1
  fi
  run_step_tty bash "$DANK_BOOTSTRAP" -c "${compositor}" -t ghostty -y --include-deps dms-greeter --danksearch --dankcalendar
  if [ "$status" -ne 0 ]; then
    echo "==> [$(date '+%H:%M:%S')] Dank install failed, retrying once..."
    run_step_tty bash "$DANK_BOOTSTRAP" -c "${compositor}" -t ghostty -y --include-deps dms-greeter --danksearch --dankcalendar
  fi
  rm -f "$DANK_BOOTSTRAP"
  if [ "$status" -ne 0 ]; then
    echo "!!  [$(date '+%H:%M:%S')] Dank install failed twice, aborting"
    exit 1
  fi

  for repo in avengemedia:danklinux avengemedia:dms; do
    repo_file="/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:${repo}.repo"
    if [ -f "$repo_file" ] && ! grep -q '^priority=' "$repo_file"; then
      sudo sh -c "echo 'priority=1' >> '$repo_file'"
    fi
  done

  ## Dank overrides ##
  if [ "$compositor" = "niri" ]; then
    echo "include optional=true \"dank_overrides.kdl\"" >>~/.config/niri/config.kdl
  else
    echo "require(\"dank_overrides\")" >>~/.config/hypr/hyprland.lua
  fi
}

## Install compositor ##
install_hyprland() {
  run_step ./install_hyprland.sh
}

install_niri() {
  run_step ./install_niri.sh
}

## Install Noctalia ##
install_noctalia() {
  run_step ./install_noctalia.sh
}

## Compositor overrides ##
# Runs after the compositor and shell are installed, so it appends to the
# config they created instead of creating a stub file (which would stop the
# compositor from writing its own default config on first launch).
append_once() {
  grep -qsF "$2" "$1" || echo "$2" >>"$1"
}

add_compositor_overrides() {
  local config
  case "$MODE" in
  niri) config=~/.config/niri/config.kdl ;;
  hypr) config=~/.config/hypr/hyprland.lua ;;
  *) return 0 ;;
  esac

  if [ ! -f "$config" ]; then
    echo "!!  $config doesn't exist yet; log in to $COMPOSITOR once, then add the override include by hand"
    FAILED_STEPS="$FAILED_STEPS
  - add_compositor_overrides: $config not found"
    return 1
  fi

  if [ "$MODE" = "niri" ]; then
    append_once "$config" 'include optional=true "niri_overrides.kdl"'
  else
    append_once "$config" 'require("hypr_overrides")'
  fi
}

install_gnome() {
  run_step ./install_gnome.sh
}

install_cosmic() {
  run_step ./install_cosmic.sh
}

install_kde() {
  run_step ./install_kde.sh
}

. /etc/os-release

if [ "$ID" == "fedora" ]; then
  run_step ./install_fedora.sh
fi

if [ "$ID" == "arch" ]; then
  run_step ./install_arch.sh
fi

run_step ./install_flatpak.sh

case "$MODE" in
hypr) install_hyprland ;;
niri) install_niri ;;
kde) install_kde ;;
gnome) install_gnome ;;
cosmic) install_cosmic ;;
esac

case "$SHELL_ARG" in
dms) install_dank "$COMPOSITOR" ;;
noctalia) install_noctalia ;;
esac

add_compositor_overrides

## Install pakcages I use ##
if [[ "$SHELL_ARG" != "dms" ]]; then
  run_step ./install_ghostty.sh
fi

run_step ./install_bitwarden.sh
run_step ./install_stow.sh
run_step ./install_brew.sh "$MODE"
run_step ./install_printer.sh
run_step ./install_zsh.sh
run_step ./install_vpn.sh
run_step ./install_tmux.sh
run_step ./install_ufw.sh
run_step ./install_docker.sh
run_step ./install_essentials.sh
run_step ./install_zen.sh
run_step ./install_freetube.sh
run_step ./install_office.sh
run_step ./install_nvim.sh
run_step ./install_qbittorrent.sh
run_step ./install_spotify.sh
run_step ./install_tor.sh
run_step ./install_vlc.sh
run_step ./install_snapper.sh
run_step ./install_whatsapp.sh

## Clone and Stow Dotfiles ##
if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  # Directory cleanup so stow can symlink cleanly, even if ghostty/nvim/tmux
  # were installed (and their default configs created) by steps above.
  rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.config/tmux ~/.local/state/nvim/ ~/.local/share/nvim/
  run_step ./install_dotfiles.sh "$MODE" "$SHELL_ARG"
fi
