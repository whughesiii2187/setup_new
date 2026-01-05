#!/bin/bash

CONNECTION_NAME=$(nmcli connection show | grep wireguard | awk '{print $1}' | head -n 1)

STATE=$(nmcli connection show $CONNECTION_NAME | grep "GENERAL.STATE" | awk '{print $2}')

if [ "$STATE" == "activated" ]; then
  nmcli connection down "$CONNECTION_NAME"
  notify-send -t 2500 "VPN Connection $CONNECTION_NAME Disconnected"
else
  nmcli connection up "$CONNECTION_NAME"
  notify-send -t 2500 "VPN Connection $CONNECTION_NAME Connected"
fi
