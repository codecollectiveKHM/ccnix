{ lib, ... }:
{
  home.stateVersion = "25.05";

  myModules.bundles = {
    cli.enable = true;
    dev.enable = true;
    personal.enable = true; # gpg/pass, syncthing, AI clients, anydesk
  };

  # ---------------------------------
  # Packages & apps only on this host
  # ---------------------------------

  myModules.apps =
    lib.genAttrs
      [
        "t3code"
        "pi" # harness
      ]
      (_: {
        enable = true;
      });

  # --------------------------------
  # Extra settings only on this host
  # --------------------------------

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
