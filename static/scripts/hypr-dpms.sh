#!/usr/bin/env bash
# hypr-dpms.sh on|off [monitor]
hyprctl dispatch "hl.dsp.dpms({ action = \"$1\"${2:+, monitor = \"$2\"} })"
