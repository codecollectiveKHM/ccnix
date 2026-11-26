#!/usr/bin/env bash

HYPRLAND_DEVICE="dell0a1f:00-0488:1024-touchpad" # Replace with your touchpad's device name

if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR=/run/user/$(id -u)
fi

export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

# $1 = true|false
set_touchpad() {
  if [ -e ~/.config/hypr/hyprland.lua ]; then
    hyprctl eval "hl.device({ name = \"$HYPRLAND_DEVICE\", enabled = $1 })"
  else
    hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" "$1"
  fi
}

enable_touchpad() {
  printf "true" >"$STATUS_FILE"
  notify-send -u normal "Enabling Touchpad"
  set_touchpad true
}

disable_touchpad() {
  printf "false" >"$STATUS_FILE"
  notify-send -u normal "Disabling Touchpad"
  set_touchpad false
}

if ! [ -f "$STATUS_FILE" ]; then
  disable_touchpad
else
  if [ $(cat "$STATUS_FILE") = "true" ]; then
    disable_touchpad
  elif [ $(cat "$STATUS_FILE") = "false" ]; then
    enable_touchpad
  fi
fi
