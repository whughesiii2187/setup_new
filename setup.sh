#!/usr/bin/env bash
#
# setup.sh — entry point for the desktop setup.
# Validates the requested mode (and shell), then hands them off to
# install_all.sh, which does the actual per-mode work.
#
# Usage:
#   ./setup.sh <hypr|niri> [dms|noctalia]
#       hypr/niri - install the compositor alone, or with a shell on top:
#                     dms      - DankMaterialShell
#                     noctalia - Noctalia Shell
#   ./setup.sh <gnome|kde|cosmic|devc>
#       gnome   - GNOME desktop (workstation-product group) + common packages
#       kde     - KDE Plasma Workspaces + common packages
#       cosmic  - COSMIC desktop + common packages
#       devc    - devcontainer only: brew + devcontainer dotfiles, then exit

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSITORS=(hypr niri)
SHELLS=(dms noctalia)
STANDALONE_MODES=(gnome kde cosmic devc)

usage() {
  echo "Usage: $0 <hypr|niri> [dms|noctalia]" >&2
  echo "       $0 <gnome|kde|cosmic|devc>" >&2
  exit 1
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
fi

MODE="$1"
SHELL_ARG="${2:-}"

is_compositor=false
for c in "${COMPOSITORS[@]}"; do
  if [[ "$MODE" == "$c" ]]; then
    is_compositor=true
    break
  fi
done

if [[ "$is_compositor" == true ]]; then
  if [[ -n "$SHELL_ARG" ]]; then
    is_valid_shell=false
    for s in "${SHELLS[@]}"; do
      if [[ "$SHELL_ARG" == "$s" ]]; then
        is_valid_shell=true
        break
      fi
    done
    if [[ "$is_valid_shell" != true ]]; then
      echo "Error: unrecognized shell '$SHELL_ARG'" >&2
      usage
    fi
  fi
else
  if [[ -n "$SHELL_ARG" ]]; then
    echo "Error: '$MODE' does not take a second argument" >&2
    usage
  fi

  is_valid=false
  for m in "${STANDALONE_MODES[@]}"; do
    if [[ "$MODE" == "$m" ]]; then
      is_valid=true
      break
    fi
  done

  if [[ "$is_valid" != true ]]; then
    echo "Error: unrecognized mode '$MODE'" >&2
    usage
  fi
fi

echo "==> setup mode: $MODE${SHELL_ARG:+ + $SHELL_ARG}"

INSTALL_ALL="$SCRIPT_DIR/scripts/install_all.sh"
if [[ ! -x "$INSTALL_ALL" ]]; then
  echo "Error: $INSTALL_ALL not found or not executable" >&2
  exit 1
fi

"$INSTALL_ALL" "$MODE" "$SHELL_ARG"
