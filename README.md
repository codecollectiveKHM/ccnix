# ccnix

NixOS + Home Manager flake for the Code Collective lab. Layout: [docs/TREE.md](docs/TREE.md)

| Host | Notes |
|---|---|
| `cc1` | ComfyUI (tailnet HTTPS), JupyterHub, RAVE, `alle` with full CLI/desktop packages |
| `cc2` | dual-boot GRUB (Ubuntu, Windows), whisper, `alle` with labguide |
| `cc3` | `alle` (no HM) |
| `cc4` | RAVE, early KMS, `alle` with pi |
| `installer` | unattended ISO (`hosts/installer/installer.nix`, target set inside) |

All hosts: user `admin`, `x86_64-linux`, NVIDIA, role `workstation`, colmena tags `workstation` `linux`.

## Daily use

```sh
ns                 # rebuild this host (alias in hosts/<h>/<h>.nix: tree update + git add -A + nixos-rebuild)
nix flake check    # format, deadnix, statix, gitleaks, Hyprland config, eval all hosts
nix fmt            # nixfmt-tree
```

One-time per clone: `git config core.hooksPath .githooks` (gitleaks + nixfmt pre-commit).

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

## Conventions

1. Every file under `modules/nixos` and `modules/home` is auto-imported and does nothing until enabled. Hosts set options; they never import feature files (except `<h>-hardware.nix`, `<h>-disko.nix`).
2. Roles and bundles only write `lib.mkDefault true`; a host opts out with a plain `= false`.
3. No literal user names or `/home/...` in `modules/`: use `config.myModules.host.user` (NixOS) or `config.home.homeDirectory` (HM). Exception: the `alle` lab account (`features/alle.nix`).
4. `inputs` is the only specialArg.
5. `modules/home` is a Home Manager `sharedModule`: every HM user (`admin`, `alle`) gets the option tree, all off.

## Common tasks

**Add a host.** `mkdir hosts/cc5`, add `cc5-meta.nix` (copy one), `cc5-hardware.nix` (`nixos-generate-config --show-hardware-config`), optional `cc5-disko.nix`, `cc5-config.nix` and `cc5.nix`. The flake picks it up automatically. Add its `/etc/ssh/ssh_host_ed25519_key.pub` to `lib/keys.nix` once secrets need it.

**Install a host.** Seed password hashes and run disko-install: see `commands.txt`, or build the ISO (`nix build .#nixosConfigurations.installer.config.system.build.isoImage`).

**Toggle a feature.**

```nix
# hosts/<h>/<h>-config.nix
myModules.roles.workstation.enable = true;   # desktop+plasma, audio, kanata, ndi
myModules.system.ollama.enable = true;
myModules.system.alle.enable = true;         # lab user; HM via home-manager.users.alle
# hosts/<h>/<h>.nix
myModules.bundles.personal.enable = false;
myModules.apps.zotero.enable = true;
```

**List what's on.** `nix eval .#nixosConfigurations.cc1.config.myModules --json | jq`

**Deploy remotely.** `colmena apply --on @workstation` (commit first: colmena can't read a dirty tree) or `nixos-rebuild switch --flake .#cc3 --target-host root@cc3`.

**Hyprland config.** Lua (`static/hypr/nixos/*.lua`, entry `hypr-choose/sources-nixos.lua`). `checks.hyprland-config` runs `Hyprland --verify-config` on cc1's generated `hyprland.lua`; an assertion requires HM `configType = "lua"`.

**Refresh the tree.** `static/scripts/readme-tree-update.sh` writes `docs/TREE.md`.

**LAN AI access.** On cc1, cc2, cc4 (`myModules.system.alle.lanSsh`), anyone on the lab wifi can `ssh alle@cc1.local` with the alle password (LAN only; tailnet stays key-only), then run `pi` against that host's ollama.
