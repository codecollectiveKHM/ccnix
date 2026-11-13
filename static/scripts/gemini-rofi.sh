#!/usr/bin/env bash
set -euo pipefail

PROMPTS="${XDG_CONFIG_HOME:-$HOME/.config}/gemini-rofi/prompts"
RTHEME='window {width: 60%;}'

mapfile -t flags < <(ls "$PROMPTS" 2>/dev/null | sed 's|\.md$||; s|^|/|')
sel=$(printf '%s\n' "${flags[@]}" |
  rofi -dmenu -p "Gemini:" \
    -theme-str "$RTHEME listview {lines: ${#flags[@]}; dynamic: true;}") || exit 0
[ -z "$sel" ] && exit 0

flag=${sel%% *}
rest=${sel#"$flag"}
rest=${rest# }
tpl="$PROMPTS/${flag#/}.md"

if [[ "$flag" == /* && -r "$tpl" ]]; then
  if [ -z "$rest" ]; then
    rest=$(rofi -dmenu -p "${flag#/}" -filter "$(wl-paste 2>/dev/null || true)" \
      -theme-str "$RTHEME listview {lines: 0;}" </dev/null) || exit 0
  fi
  PROMPT="$(<"$tpl")"$'\n\n'"$rest"
else
  PROMPT="$sel"
fi

[ -z "$PROMPT" ] && exit 0
Q=$(jq -rn --arg x "$PROMPT" '$x|@uri')
firefox --new-tab "https://gemini.google.com/u/0/app?q=$Q"
