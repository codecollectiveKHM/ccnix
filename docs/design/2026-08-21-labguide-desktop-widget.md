# agsdesk — dynamic desktop widget

> Design record for labguide (`static/labguide`, `modules/home/apps/labguide.nix`); it was called agsdesk while being designed.

**Date:** 2026-08-21
**Status:** Design approved, ready for implementation planning

## Summary

A always-on desktop widget that sits above the wallpaper and below every application
window. The left half is a launcher: auto-discovered GUI applications beside a curated
list of CLI packages, each clickable to launch and hoverable for a description. The right
half is reference material: a fastfetch readout above a hand-written table of Nix command
explainers.

It runs as a systemd user service so it starts under both Hyprland and Plasma 6 Wayland,
and it is a second, independent AGS instance so a Hyprland-specific crash in the existing
`visual-keyboard` config cannot take it down.

## Goals

- A live, clickable desktop surface replacing dead wallpaper space.
- Zero new packages: everything is already in the flake.
- Works in both the Hyprland session and the Plasma 6 Wayland session.
- Package tooltips sourced from nixpkgs metadata so they cannot drift.
- JS/CSS/JSON editable without a rebuild.

## Non-goals

- Plasma X11 support. `gtk-layer-shell` binds `zwlr_layer_shell_v1`, a Wayland protocol
  with no X11 equivalent. The service skips X11 sessions cleanly rather than crash-looping.
- A toggle keybind. A Hyprland `bind` has no Plasma counterpart, so the widget would
  behave differently per session. Always-on is the only WM-agnostic model.
- Replacing hyprpaper. The wallpaper image stays exactly where it is.

## Prior art in this repo

| Concern | Existing example to follow |
| --- | --- |
| Module shape (`options` + `lib.mkIf`) | `modules/apps/ags.nix` |
| Mutable out-of-store config symlink | `modules/apps/ags.nix`, `bundles/dotfiles.nix` (nvim) |
| systemd user service in home-manager | `modules/apps/stirling-pdf.nix`, `modules/apps/polkit.nix` |
| Module option beyond `enable` | `modules/apps/stirling-pdf.nix` (`host`) |
| AGS v1 widget code, JSON-driven | `static/ags/config.js` |
| Opt-in wiring | `modules/bundles/common.nix` |

## Environment facts (verified 2026-08-21)

- AGS is `1.9.0`, from flake input `ags.url = "github:Aylur/ags/v1"`.
- `ags -b <bus-name> -c <path>` runs an independent second instance.
- KWin 6.6 exports `zwlr_layer_shell_v1` (found in `libkwin.so`), so layer-shell surfaces
  work under Plasma 6 Wayland.
- `gui-config.nix` enables `services.desktopManager.plasma6` and `programs.hyprland`
  together behind SDDM — the dual-session case is real.
- hyprpaper renders the wallpaper on the `background` layer via
  `static/hypr/hyprpaper.conf`.

## Architecture

### Why a separate AGS instance

`static/ags/config.js` imports `resource:///com/github/Aylur/ags/service/hyprland.js` at
module top level. Under Plasma there is no `HYPRLAND_INSTANCE_SIGNATURE`, that service
fails to initialise, and the entire daemon exits. Merging the desktop widget into that
config would make it Hyprland-only by inheritance.

The new instance imports no Hyprland service at all — it needs none.

```
ags -b visual-keyboard -c ~/.config/ags/config.js       # Hyprland only, unchanged
ags -b agsdesk         -c ~/.config/agsdesk/config.js   # WM-agnostic, new
```

### Layer position

wlr-layer-shell stacks `background < bottom < [normal windows] < top < overlay`. The
widget takes `bottom`: above hyprpaper's wallpaper, below every application window.

```
  overlay    ← visual-keyboard (existing)
  top        ← waybar
  ---------- normal application windows ----------
  bottom     ← agsdesk                    ◀ this widget
  background ← hyprpaper wallpaper.png
```

Under Plasma, plasmashell draws its own desktop containment. A `bottom` surface is
expected to render above it, but this is unverified without a live Plasma session. If the
stacking lands wrong, the fallback is `layer: "top"` with `exclusivity: "ignore"`.

### File layout

```
modules/apps/agsdesk.nix           Nix: options, generated JSON, systemd service
        ├─ generates → ~/.config/agsdesk/packages.json
        ├─ generates → ~/.config/agsdesk/fastfetch.jsonc
        ├─ symlinks  → ~/.config/agsdesk/*  (mkOutOfStoreSymlink → static/agsdesk/)
        └─ defines   → systemd.user.services.agsdesk

static/agsdesk/
  config.js              entry point; App.config({ windows: [Desktop()] })
  widgets/apps.js        auto column — AGS Applications service
  widgets/packages.js    curated column — reads packages.json
  widgets/fastfetch.js   execAsync fastfetch --pipe -c fastfetch.jsonc
  widgets/nixhelp.js     reads nix-commands.json
  nix-commands.json      hand-written by the user
  style.css
```

Splitting the widgets into one file per pane keeps each under ~80 lines and lets a pane be
edited without reading the others. `static/ags/config.js` is 425 lines in one file and is
the counter-example being avoided.

## Layout

Outer split is vertical (left | right). The right half is split by a horizontal line.

```
┌───────────────────────────────┬───────────────────────────────┐
│  APPLICATIONS  │  PACKAGES    │   FASTFETCH                   │
│  (auto)        │  (curated)   │   os / kernel / uptime        │
│  Firefox       │  btop        │   packages / wm / shell       │
│  Obsidian      │  bat         ├───────────────────────────────┤
│  Kitty         │  jq          │   NIX COMMANDS                │
│  Zotero        │  yazi        │   nix flake update — ...      │
│  ...  (scroll) │  lazygit     │   nixos-rebuild switch — ...  │
└───────────────────────────────┴───────────────────────────────┘
        LEFT HALF (launcher)              RIGHT HALF (reference)
```

The window anchors to all four screen edges with `exclusivity: "ignore"` so it never
reserves space from other clients.

## Components

### 1. `modules/apps/agsdesk.nix`

Option surface:

```nix
myModules.apps.agsdesk = {
  enable = true;
  terminal = "kitty";                    # default
  packages = [
    "btop" "yazi" "lazygit"              # bare string → kitty -e <name>
    { name = "jq";  action = "man jq"; } # override → kitty -e man jq
    { name = "bat"; action = "bat --help"; }
  ];
};
```

`packages` is `listOf (either str (submodule { name; action ? null; icon ? null; }))`.

At build time each entry is resolved against `pkgs`, `meta.description` is read, and
`packages.json` is written:

```json
[ { "name": "btop", "desc": "A monitor of resources", "exec": "kitty -e btop", "icon": null } ]
```

An entry naming a package absent from `pkgs` fails evaluation loudly rather than rendering
an empty tile at runtime.

`fastfetch.jsonc` is generated separately from `static/fastfetch/config.jsonc` so the pane's
module list can be tuned without changing the terminal fastfetch.

Everything else in `static/agsdesk/` is exposed through `mkOutOfStoreSymlink`, matching
`ags.nix`, so JS/CSS/JSON edits take effect on
`systemctl --user restart agsdesk` with no rebuild.

### 2. systemd user service

```nix
systemd.user.services.agsdesk = {
  Unit = {
    Description = "AGS desktop widget";
    After = [ "graphical-session.target" ];
    PartOf = [ "graphical-session.target" ];
    ConditionEnvironment = "WAYLAND_DISPLAY";
  };
  Service = {
    ExecStart = "${ags}/bin/ags -b agsdesk -c %h/.config/agsdesk/config.js";
    Restart = "on-failure";
    RestartSec = 3;
  };
  Install.WantedBy = [ "graphical-session.target" "hyprland-session.target" ];
};
```

Plasma 6 reaches `graphical-session.target` natively. Hyprland reaches it via the
`dbus-update-activation-environment --systemd` and `systemctl --user import-environment`
lines already at the top of `static/hypr/conf/autostart.conf`; home-manager's hyprland
module additionally provides `hyprland-session.target`. Both appear in `WantedBy` because
which one fires depends on the session, and a target that never activates is harmless.

`ConditionEnvironment = "WAYLAND_DISPLAY"` makes a Plasma X11 login skip the unit silently
instead of restart-looping against a protocol that cannot bind.

### 3. Applications pane (`widgets/apps.js`)

Uses the built-in AGS `Applications` service, which parses `.desktop` files across
`XDG_DATA_DIRS` and yields `name`, `description`, `icon_name`, and `.launch()`. Each entry
renders as a `Widget.Button` with `tooltipText` set to the description, inside a
`Widget.Scrollable` since the list runs to 100+ entries. Entries with
`NoDisplay=true` are filtered out.

### 4. Packages pane (`widgets/packages.js`)

Reads `packages.json` once at startup, renders one button per entry with `tooltipText`
from `desc` and `onClicked` running `exec` through `Utils.execAsync`.

### 5. Fastfetch pane (`widgets/fastfetch.js`)

`Utils.execAsync(["fastfetch", "--pipe", "-c", fastfetchConfigPath])` into a monospace
`Widget.Label`. Refreshed on a `Utils.interval` so uptime does not go stale; the interval
is a constant at the top of the file.

### 6. Nix commands pane (`widgets/nixhelp.js`)

Reads `nix-commands.json`, a hand-written file grouped by category:

```json
{
  "Flakes": [
    { "cmd": "nix flake update", "desc": "Bump every input in flake.lock" },
    { "cmd": "nix flake update <input>", "desc": "Bump a single input only" }
  ],
  "Rebuild": [
    { "cmd": "sudo nixos-rebuild switch --flake .#imac", "desc": "Apply and activate" }
  ]
}
```

Renders category headers with a `cmd` / `desc` row per entry. Read-only, no click action.

## Data flow

```
nixpkgs meta.description ──build──▶ packages.json ──runtime──▶ packages pane
.desktop files ─────────────────────────────────────runtime──▶ applications pane
fastfetch.jsonc ──▶ fastfetch --pipe ────────────────runtime──▶ fastfetch pane
nix-commands.json (hand-written) ────────────────────runtime──▶ nix commands pane
```

The only build-time step is `packages.json`. Every other input is read live, so three of
the four panes are editable without a rebuild.

## Error handling

Each pane fails independently; the daemon staying alive outranks any single pane.

- Missing or malformed `packages.json` / `nix-commands.json`: pane renders an inline
  notice and the rest of the widget is unaffected. `JSON.parse` is wrapped, matching the
  `try/catch` already used in `static/ags/config.js`.
- `fastfetch` non-zero exit: stderr is rendered in the pane rather than swallowed.
- `.desktop` entry with no icon: falls back to a generic icon name.
- Launch failure: logged via `console.error`, no crash.

## Verification

There is no test framework for a GTK shell, so verification is manual and staged:

1. **Eval** — `nix build` / the host's `ns` alias. Catches option-type errors and a
   `packages` entry naming a package that does not exist.
2. **Foreground run** — `ags -b agsdesk -c ~/.config/agsdesk/config.js` in a terminal, so
   JS exceptions print directly instead of disappearing into the journal. `-i` opens the
   GTK inspector for layout debugging.
3. **Service** — `systemctl --user status agsdesk` and `journalctl --user -u agsdesk` after
   a Hyprland login.
4. **Plasma** — log into "Plasma (Wayland)" from SDDM once and confirm the widget appears
   above the plasmashell desktop and below application windows. This is the one item that
   cannot be checked ahead of time.
5. **X11 guard** — log into "Plasma (X11)" and confirm the unit reports
   `condition failed` rather than restart-looping.

## Open risk

Layer stacking against plasmashell's desktop containment (see Architecture). Fallback is
documented; it is a one-word change.
