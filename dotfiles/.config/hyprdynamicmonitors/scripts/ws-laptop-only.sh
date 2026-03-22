#!/usr/bin/env bash
# ws-laptop-only.sh
# Reorganizes workspaces after switching to: laptop only (no externals)
#
# All workspaces collapse onto eDP-1

# sleep 2

hyprctl dispatch moveworkspacetomonitor 1 eDP-1
hyprctl dispatch moveworkspacetomonitor 2 eDP-1
hyprctl dispatch moveworkspacetomonitor 3 eDP-1
hyprctl dispatch moveworkspacetomonitor 4 eDP-1
hyprctl dispatch moveworkspacetomonitor 5 eDP-1

hyprctl reload
