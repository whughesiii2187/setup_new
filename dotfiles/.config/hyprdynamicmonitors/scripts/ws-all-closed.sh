#!/usr/bin/env bash
# ws-all-closed.sh
# Reorganizes workspaces after switching to: all monitors, lid closed (clamshell)
#
# Workspaces shift left onto the 3 remaining external monitors:
#   DP-3  → workspace 1
#   DP-4  → workspace 2
#   DP-1  → workspaces 3, 4, 5

# sleep 2

hyprctl dispatch moveworkspacetomonitor 1 DP-3
hyprctl dispatch moveworkspacetomonitor 2 DP-4
hyprctl dispatch moveworkspacetomonitor 3 DP-1
hyprctl dispatch moveworkspacetomonitor 4 DP-1
hyprctl dispatch moveworkspacetomonitor 5 DP-1

hyprctl reload
