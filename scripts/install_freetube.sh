#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  flatpak install -y flathub io.freetubeapp.FreeTube >/dev/null 2>&1
fi
