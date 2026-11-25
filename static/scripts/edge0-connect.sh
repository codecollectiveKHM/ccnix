#!/usr/bin/env bash
# Use cc2's Edge0 from any LAN computer with pi (Linux, macOS, WSL/Git Bash). See docs/EDGE0.md.
#   edge0-connect.sh up       install pi if missing, tunnel localhost:18000 → cc2:8000,
#                             start edge0 if idle, add the pi provider
#   edge0-connect.sh down     close the tunnel (edge0 keeps running for others)
#   edge0-connect.sh status
# Env overrides: EDGE0_HOST (cc2.local) EDGE0_USER (alle) EDGE0_PORT (18000) PI_VERSION (1.6.0)
# Needs Node.js >= 22.19 (pi's requirement); pi goes to ~/.local via npm, no sudo.
set -euo pipefail

host=${EDGE0_HOST:-cc2.local}
user=${EDGE0_USER:-alle}
port=${EDGE0_PORT:-18000}
dest="$user@$host"
sock="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/edge0-tunnel-$port.sock"
url="http://localhost:$port/v1"
models="$HOME/.pi/agent/models.json"
pi_version=${PI_VERSION:-1.6.0} # same pin as pkgs/pi-coding-agent.nix

tunnel_up() { ssh -S "$sock" -O check "$dest" 2>/dev/null; }
answering() { curl -fsS --max-time 5 "$url/models" >/dev/null 2>&1; }

ensure_pi() {
  if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
    echo "node/npm not found: install Node.js 22.19+ (nodejs.org or your package manager), then rerun" >&2
    exit 1
  fi
  if ! node -e 'const [a, b] = process.versions.node.split(".").map(Number); process.exit(a > 22 || (a === 22 && b >= 19) ? 0 : 1)'; then
    echo "Node.js $(node -v) is too old for pi: need 22.19+" >&2
    exit 1
  fi
  if command -v pi >/dev/null || [ -x "$HOME/.local/bin/pi" ]; then return; fi
  echo "pi: not found, installing @earendil-works/pi-coding-agent@$pi_version into ~/.local"
  npm install --global --prefix "$HOME/.local" "@earendil-works/pi-coding-agent@$pi_version"
  case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) echo "pi: add ~/.local/bin to PATH (~/.bashrc or ~/.zshrc): export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
  esac
}

add_provider() {
  # ccnix/hm hosts: Home Manager owns the file and already has the edge0-cc2 endpoint
  if [ -L "$models" ] && [[ $(readlink "$models") == /nix/store/* ]]; then
    echo "pi: $models is managed by Nix; nothing to add"
    return
  fi
  command -v node >/dev/null || {
    echo "pi: node not found; add the provider by hand (docs/EDGE0.md)" >&2
    return 1
  }
  mkdir -p "$(dirname "$models")"
  MODELS="$models" URL="$url" node -e '
    const fs = require("fs"), f = process.env.MODELS;
    const old = fs.existsSync(f) ? fs.readFileSync(f, "utf8") : "";
    const j = old ? JSON.parse(old) : {};
    j.providers = j.providers || {};
    j.providers["edge0-cc2"] = {
      baseUrl: process.env.URL, api: "openai-completions", apiKey: "none",
      models: [{ id: "edge0_145b", name: "Edge0 145B (cc2)", contextWindow: 131072,
                 supportsTools: true, supportsImages: false }],
    };
    const out = JSON.stringify(j, null, 2) + "\n";
    if (out === old) { console.log("pi: edge0-cc2 provider already present"); process.exit(0); }
    if (old) fs.copyFileSync(f, f + ".bak");
    fs.writeFileSync(f, out);
    console.log("pi: added edge0-cc2 to " + f + (old ? " (backup: models.json.bak)" : ""));
  '
}

case "${1:-up}" in
up)
  ensure_pi
  if ! tunnel_up; then
    echo "tunnel: localhost:$port → $host:8000 (password of $user)"
    ssh -fNM -S "$sock" -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 \
      -L "$port:localhost:8000" "$dest"
  fi
  if ! answering; then
    echo "edge0 not running on $host; starting it (1-2 min)"
    ssh -S "$sock" "$dest" edge0 start # reuses the tunnel's login
  fi
  add_provider
  if answering; then echo "ready: pi → /model → Edge0 145B (cc2)"; else
    echo "edge0 not answering: $0 status; on $host: edge0 status" >&2
    exit 1
  fi
  ;;
down)
  if tunnel_up; then
    ssh -S "$sock" -O exit "$dest" 2>/dev/null
    echo "tunnel closed (edge0 still runs on $host; '$0 stop-server' only if nobody needs it)"
  else
    echo "no tunnel"
  fi
  ;;
stop-server)
  ssh "$dest" edge0 stop
  ;;
status)
  command -v pi >/dev/null && echo "pi: $(command -v pi)" || echo "pi: not on PATH"
  tunnel_up && echo "tunnel: up (localhost:$port)" || echo "tunnel: down"
  answering && echo "edge0: answering" || echo "edge0: not reachable"
  ;;
*)
  echo "usage: $0 [up|down|status|stop-server]" >&2
  exit 2
  ;;
esac
