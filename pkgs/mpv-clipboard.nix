# Play the clipboard URL in mpv (Super+Shift+Y)
{
  writeShellApplication,
  mpv,
  yt-dlp,
  nodejs,
  wl-clipboard,
  libnotify,
}:
writeShellApplication {
  name = "mpv-clipboard";
  runtimeInputs = [
    mpv
    yt-dlp
    nodejs
    wl-clipboard
    libnotify
  ];
  text = ''
    URL=$(wl-paste)
    [[ -z "$URL" ]] && notify-send "mpv-clipboard" "Clipboard empty" && exit 1
    notify-send "Fetching Video..." "$URL"
    mpv --no-terminal "$URL" &
    disown
  '';
}
