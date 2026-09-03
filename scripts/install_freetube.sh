#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  flatpak_install flathub io.freetubeapp.FreeTube
fi
