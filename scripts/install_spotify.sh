#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  flatpak_install flathub com.spotify.Client
fi
