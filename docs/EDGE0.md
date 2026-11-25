# Edge0-145B on cc2

Edge0-145B (q3k) runs on cc2 (RTX 5090, 190 GB RAM) as `edge0.service`: an
OpenAI/Anthropic-compatible API on `127.0.0.1:8000`, ~150 tok/s decode, ~4000 tok/s prefill.
It is **on demand** and **shared**: one server for everyone, and **ollama on cc2 is stopped
while it runs** (it comes back when edge0 stops).

Config: `modules/nixos/features/edge0.nix` (server) · `myModules.ai.endpoints` (client: pi).

## 1. Use it on cc2 (any LAN machine or phone)

```sh
ssh alle@cc2.local          # password: alle · phone/Termux: ssh alle@10.10.2.2
edge0 status                # active = someone already started it
edge0 start                 # loads in 1-2 min, prints "ready"
pi                          # then /model → Edge0 145B
edge0 stop                  # when done, only if nobody else is using it
```

pi works on **cc2's files** (the `alle` home there). Password SSH is LAN-only;
over Tailscale use a key.

## 2. Use cc2's GPU with another machine's files (tunnel)

For an agent working on repos that live on cc1/cc4/your laptop:

```sh
ssh alle@cc2.local edge0 start                  # or start it as in 1.
ssh -fN -L 8000:localhost:8000 alle@cc2.local   # tunnel: local :8000 → cc2
curl -s localhost:8000/v1/models                # check
pi                                              # /model → Edge0 145B (cc2)
pkill -f 'L 8000:localhost:8000'                # close the tunnel
```

The client machine needs the endpoint once, in its HM config (`hosts/<h>/<h>.nix`, or the
`home-manager.users.alle` block for the lab account):

```nix
myModules.ai.endpoints.edge0 = {
  baseUrl = "http://localhost:8000/v1";
  models.edge0_145b = { name = "Edge0 145B (cc2)"; contextWindow = 131072; };
};
```

Not on NixOS: point any OpenAI-compatible client at `http://localhost:8000/v1`,
model `edge0_145b`, any API key.

## 3. Admin (cc2)

| Task | Command |
|---|---|
| Logs | `journalctl -u edge0 -f` |
| GPU | `nvidia-smi --query-gpu=memory.used,utilization.gpu --format=csv -l 2` |
| PLE table locked in RAM (~50 GB) | `grep VmLck /proc/$(pgrep -x strata)/status` |
| Speed of the last requests | `journalctl -u edge0 \| grep -o '{"time".*' \| jq -c '{in:.input_tokens,out:.generated_tokens,decode:.decode_tokens_per_second,prefill:.prefill_tokens_per_second}'` |
| Expert cache hit rate | `journalctl -u edge0 \| grep 'expert cache' \| tail` |

**Settings** (in `edge0.nix`): `ple-io=ram` (+8% prefill, needs `LimitMEMLOCK`),
`vramReserveMib` (default 3000: VRAM left for the desktop and request graphs).
Below ~100% cache hits on real work, try `vramReserveMib = 2000`.

**Update Edge0** (built by hand, not packaged; run inside `~/src/edge0`, direnv loads the
dev shell from `~/src/edge0-env`):

```sh
edge0 stop
cd ~/src/edge0 && git pull
cd edge0-strata && cmake --build build --target strata
cd ../edge0-infer && cmake --build --preset cpu --target edge0-infer
edge0 start
```

Model files: `~/models/Edge0-145B-q3k` (`hf download Edge0/Edge0-145B-q3k --local-dir ...`).
Check them with `build/cpu/bin/edge0-infer inspect --model ~/models/Edge0-145B-q3k`.

## 4. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `Permission denied` for alle | password not `alle` on that host: `echo 'alle:alle' \| sudo chpasswd` (NixOS sets it only at install) |
| Phone: no ping to 10.10.2.x | wifi client isolation or a separate wifi subnet: router setting |
| `edge0: command not found` | host not rebuilt: `git pull && ns` (or `colmena apply --on cc2`) |
| `edge0 failed` | `journalctl -u edge0 -n 30`; port 8000 busy (a manual `edge0-infer serve`?) or VRAM taken |
| `verify: instantiate: out of memory` | VRAM full: raise `vramReserveMib`, close GPU apps |
| pi on cc2 can't find gemma | edge0 is running, so ollama is stopped: `edge0 stop` |
| alle can't see `journalctl -u edge0` | by design (system logs); use `edge0 status` / ask admin |

## Notes

- Requests queue: several users work, but each waits for the others.
- `127.0.0.1` keeps the API off the network; every account on cc2 (incl. LAN `alle`
  sessions) can still use it. The service is sandboxed: home read-only, loopback-only
  network (`IPAddressDeny=any`), no new privileges.
- Edge0 was released 2026-11-12: treat it as untrusted code.
