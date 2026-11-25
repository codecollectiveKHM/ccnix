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
## Layout

```
flake.nix               outputs only; hosts are discovered from hosts/*/*-meta.nix
lib/default.nix         mkNixos / nixosModules / nixpkgsArgs (unfree + NUR + pkgs/ overlay)
lib/keys.nix            SSH pubkeys → authorized_keys and agenix recipients
hosts/<h>/              <h>-meta.nix · <h>-config.nix (NixOS) · <h>.nix (HM) · <h>-hardware.nix · <h>-disko.nix
modules/common/host.nix myModules.host.{name,user,flakePath}
modules/nixos/          base/ (always on) · desktop/ hardware/ features/ roles/ (option-gated)
modules/home/           apps/ (myModules.apps.*) · bundles/ (cli, desktop, dev, personal)
modules/experiments/    not auto-imported; add to a host's imports to try
pkgs/                   local derivations → pkgs.<name>, nix build .#<name>
secrets/                agenix (*.age + secrets.nix)
static/                 dotfiles linked by the modules
```

**List what's on.** `nix eval .#nixosConfigurations.cc1.config.myModules --json | jq`

## Conventions

1. Every file under `modules/` is auto-imported and does nothing until enabled; hosts only set options.
2. Roles and bundles only write `lib.mkDefault true`; a host or user opts out with a plain `= false`.
3. HM follows the NixOS switch via `osConfig`: polkit/plasma/kanata for every user; the desktop bundle and flatpak for the primary user only (lab users such as `alle` opt in).
4. No literal user names or `/home/...` in shared modules: `config.myModules.host.user` (NixOS), `config.home.homeDirectory` (HM).

## Updates

`update-flake-lock` opens a `flake.lock` PR every Monday and runs `check` on it; merge when green, then `colmena apply --on @workstation`.
Pinned by hand: pi 1.6.0 in `pkgs/pi-coding-agent.nix` (`npm view @earendil-works/pi-coding-agent version`).
