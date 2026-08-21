#!/usr/bin/env bash
#
# setup.sh — entry point for the desktop setup.
# Validates the requested mode, then hands it off as $1 to
# install_all.sh, which does the actual per-mode work.
#
# Usage: ./setup.sh <mode>
#   install   - baseline packages/config common to every setup
#   dms       - DankMaterialShell + its requirements
#   omarchy   - Omarchy-specific setup
#   hyprland  - vanilla Hyprland + default Quickshell base
#   devc      - devcontainer only: brew + devcontainer dotfiles, then exit

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALID_MODES=(install dms omarchy hyprland devc)

usage() {
  echo "Usage: $0 <mode>" >&2
  echo "  mode must be one of: ${VALID_MODES[*]}" >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

MODE="$1"

is_valid=false
for m in "${VALID_MODES[@]}"; do
  if [[ "$MODE" == "$m" ]]; then
    is_valid=true
    break
  fi
done

if [[ "$is_valid" != true ]]; then
  echo "Error: unrecognized mode '$MODE'" >&2
  usage
fi

echo "==> setup mode: $MODE"

INSTALL_ALL="$SCRIPT_DIR/scripts/install_all.sh"
if [[ ! -x "$INSTALL_ALL" ]]; then
  echo "Error: $INSTALL_ALL not found or not executable" >&2
  exit 1
fi

"$INSTALL_ALL" "$MODE"
