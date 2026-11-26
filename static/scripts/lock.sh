#!/bin/bash
# 1. Switch to an empty workspace to hide your windows
if [ -e ~/.config/hypr/hyprland.lua ]; then
  hyprctl dispatch 'hl.dsp.focus({ workspace = "empty" })'
else
  hyprctl dispatch workspace empty
fi

# 2. Briefly wait for the workspace transition to finish (optional)
sleep 0.1

# 3. Launch the lock screen
# hyprlock
pidof hyprlock || hyprlock       # command run before sleep
