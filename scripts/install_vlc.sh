#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  dnf install -y vlc >/dev/null 2>&1
fi
