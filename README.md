# ccnix

Code Collective lab NixOS fleet. Layout: [docs/TREE.md](docs/TREE.md)

| Host | Notes |
|---|---|
| `cc1` | 5090, Ryzen 9 9950X, 186GB RAM, (NixOS/Ubuntu/Windows11) |
| `cc2` | 5090, Ryzen 9 9950X, 186GB RAM, (NixOS/Ubuntu/Windows11) |
| `cc3` | 3070, i7-7700K, 32GB RAM, (NixOS/Ubuntu/Windows10) |
| `cc4` | 3090Ti, i7-7700K, 32GB RAM, (NixOS/Ubuntu) |
| `cc5` | 2x4090, ?, ? (Ubuntu) |

## Daily use

```sh
ns                 # rebuild this host (alias in modules/home/apps/zsh.nix: tree update + git add -A + nixos-rebuild)
nix flake check    # format, deadnix, statix, gitleaks, Hyprland config, eval all hosts
nix fmt            # nixfmt-tree
```
**List what's on.** `nix eval .#nixosConfigurations.cc1.config.myModules --json | jq`

## Updates

`update-flake-lock` opens a `flake.lock` PR every Monday and runs `check` on it; merge when green, then `colmena apply --on @workstation`.
Pinned by hand: pi 1.6.0 in `pkgs/pi-coding-agent.nix` (`npm view @earendil-works/pi-coding-agent version`).
