#!/usr/bin/env bash

# Define the target monitor
MONITOR="HDMI-A-1"
SCALE="1.75"

# Ask Hyprland for the current transform state of the monitor using jq
CURRENT_TRANSFORM=$(hyprctl monitors -j | jq -r ".[] | select(.name==\"$MONITOR\") | .transform")

# $1 = transform (0 normal, 1 = 90°)
set_transform() {
  if [ -e ~/.config/hypr/hyprland.lua ]; then
    hyprctl eval "hl.monitor({ output = \"$MONITOR\", mode = \"3840x2160@60\", position = \"auto\", scale = $SCALE, transform = $1 })"
  else
    hyprctl keyword monitor "$MONITOR, 3840x2160@60, auto, $SCALE, transform, $1"
  fi
}

# If it's currently normal (0), rotate it to 90 degrees (1).
# Otherwise, set it back to normal (0).
if [ "$CURRENT_TRANSFORM" = "0" ]; then
  set_transform 1
  notify-send "Rotation" "Screen set to Portrait"
else
  set_transform 0
  notify-send "Rotation" "Screen set to Landscape"
fi
