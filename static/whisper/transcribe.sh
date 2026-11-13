usage() { echo "usage: transcribe [-l lang] [-f txt|srt|vtt|json] [-o dir] [file|url|-]" >&2; exit 1; }
lang=auto fmt=txt out="" name="" url=""
while getopts l:f:o:h opt; do
  case $opt in l) lang=$OPTARG ;; f) fmt=$OPTARG ;; o) out=$OPTARG ;; *) usage ;; esac
done
shift $((OPTIND - 1))
arg=${1:--}
[[ $fmt =~ ^(txt|srt|vtt|json)$ ]] || usage
if [[ $arg == - && -t 0 ]]; then usage; fi

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

# Spotify → show/title from page meta → iTunes → RSS → enclosure URL (sets name, url)
# shellcheck disable=SC2016
spotify_resolve() {
  local page show feed
  page=$(curl -fsL -A 'Mozilla/5.0' "$1")
  name=$(htmlq -a content 'meta[property="og:title"]' <<<"$page")
  show=$(htmlq -a content 'meta[name="description"]' <<<"$page" |
    sed -n 's/^Listen to this episode from \(.*\) on Spotify\..*/\1/p')
  if [[ -z $name || -z $show ]]; then echo "spotify: can't read show/title" >&2; return 1; fi
  echo "spotify: $show — $name" >&2
  feed=$(curl -fsG https://itunes.apple.com/search --data-urlencode "term=$show" -d media=podcast -d limit=5 |
    jq -r --arg s "$show" '([.results[] | select(.collectionName == $s)][0] // .results[0]).feedUrl // empty')
  if [[ -z $feed ]]; then echo "no public RSS (Spotify exclusive?)" >&2; return 1; fi
  url=$(curl -fsL "$feed" | xq -r --arg t "$name" '
    [.rss.channel.item | if type == "array" then .[] else . end
     | select(.title | tostring | ascii_downcase | startswith($t | ascii_downcase | .[0:40]))][0]
    .enclosure."@url" // empty')
  if [[ -z $url ]]; then echo "episode not found in $feed" >&2; return 1; fi
  name=${name//\//-}
}

case $arg in
  -) cat >"$tmp/src" ;;
  *open.spotify.com/episode/*) spotify_resolve "$arg"; curl -fsL "$url" -o "$tmp/src" ;;
  http*)
    yt-dlp -q --no-playlist -x -o "$tmp/%(title).60B.%(ext)s" "$arg"
    f=$(find "$tmp" -type f | head -1); name=$(basename "${f%.*}"); mv "$f" "$tmp/src" ;;
  *) [[ -f $arg ]] || usage; name=$(basename "${arg%.*}"); ln -s "$(realpath "$arg")" "$tmp/src" ;;
esac
name=${name:-transcript}

ffmpeg -nostdin -loglevel error -i "$tmp/src" -ar 16000 -ac 1 "$tmp/a.wav"
flag="-o$fmt"; [[ $fmt != json ]] || flag=-oj
whisper-cli -m "$MODEL" --vad -vm "$VAD" -mc 0 -l "$lang" -np "$flag" -of "$tmp/out" -f "$tmp/a.wav" >/dev/null

if [[ -t 1 || -n $out ]]; then
  dest="${out:-$PWD}/$name.$fmt"; mkdir -p "$(dirname "$dest")"; cp "$tmp/out.$fmt" "$dest"; echo "$dest"
else
  cat "$tmp/out.$fmt"
fi
