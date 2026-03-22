#!/usr/bin/env bash
# ws-all-open.sh
# Reorganizes workspaces after switching to: all monitors, lid open
#
# Target layout:
#   eDP-1 → workspace 1
#   DP-3  → workspace 2
#   DP-4  → workspace 3
#   DP-1  → workspaces 4, 5

# sleep 2

hyprctl dispatch moveworkspacetomonitor 1 eDP-1
hyprctl dispatch moveworkspacetomonitor 2 DP-3
hyprctl dispatch moveworkspacetomonitor 3 DP-4
hyprctl dispatch moveworkspacetomonitor 4 DP-1
hyprctl dispatch moveworkspacetomonitor 5 DP-1

hyprctl reload
