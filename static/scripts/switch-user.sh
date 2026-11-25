#!/usr/bin/env bash
# SDDM login screen for another user (Super+Shift+S, also on the hyprlock screen).
# This session stays locked and running; its owner logs in again to return to it.
set -euo pipefail
seat=$(busctl --system get-property org.freedesktop.DisplayManager /org/freedesktop/DisplayManager \
  org.freedesktop.DisplayManager Seats | grep -o '/org/[^"]*' | head -n1)
exec busctl --system call org.freedesktop.DisplayManager "${seat:?no SDDM seat}" \
  org.freedesktop.DisplayManager.Seat SwitchToGreeter
