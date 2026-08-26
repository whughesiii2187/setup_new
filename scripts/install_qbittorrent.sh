#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  dnf install -y qbittorrent >/dev/null 2>&1
fi
