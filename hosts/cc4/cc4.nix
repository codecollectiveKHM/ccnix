{ lib, ... }:
{
  home.stateVersion = "25.05";

  myModules.bundles = {
    cli.enable = true;
    desktop.enable = true;
    dev.enable = true;
    personal.enable = true; # gpg/pass, syncthing, AI clients, anydesk
  };

  myModules.apps =
    lib.genAttrs
      [
        "yazi-portal" # NixOS yazi portal picker
        "flatpak"
        "t3code"
        "pi" # gemma4
      ]
      (_: {
        enable = true;
      });

  wayland.windowManager.hyprland.extraConfig = ''
    hl.config({
      input  = { sensitivity = -1.0 },
      cursor = { no_hardware_cursors = true },
    })
  '';

  programs.zsh.envExtra = ''
    export STARSHIP_HOST_ICON="*󰲦 "
  '';
}
