# Toggle: 1st call starts recording, 2nd call transcribes, types at cursor, copies to clipboard
d="${XDG_RUNTIME_DIR:-/tmp}"; pid="$d/dictate.pid"; wav="$d/dictate.wav"
if [[ -f $pid ]]; then
  p=$(<"$pid"); rm -f "$pid"; kill -INT "$p" || true; sleep 0.3
  txt=$(whisper-cli -m "$MODEL" --vad -vm "$VAD" -l "${DICTATE_LANG:-auto}" -nt -np -f "$wav" |
    tr -s '\n ' ' ' | sed 's/^ //; s/ $//')
  [[ -n $txt ]] || exit 0
  wl-copy "$txt"; wtype "$txt"; notify-send -t 1500 dictate "done"
else
  pw-record --rate 16000 --channels 1 "$wav" & echo $! >"$pid"
  notify-send -t 1500 dictate "recording…"
fi
