# Shared: ensure models exist in ~/.local/share/whisper (downloads go to stderr)
M="$HOME/.local/share/whisper"; mkdir -p "$M"
MODEL="$M/ggml-large-v3-turbo.bin"; VAD="$M/ggml-silero-v5.1.2.bin"
[ -f "$MODEL" ] || (cd "$M" && whisper-cpp-download-ggml-model large-v3-turbo) >&2
[ -f "$VAD" ] || curl -fL -o "$VAD" https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v5.1.2.bin
