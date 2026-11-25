{ lib, ... }:
{
  home.stateVersion = "25.05";

  myModules.bundles = {
    cli.enable = true;
    dev.enable = true;
    personal.enable = true; # gpg/pass, syncthing, AI clients, anydesk
  };

  myModules.apps =
    lib.genAttrs
      [
        "yazi-portal" # NixOS yazi portal picker
        "labguide" # desktop widget (list: modules/home/apps/labguide.nix)
        "pureref"
        "t3code"
        "pi" # gemma4
        "whisper" # whisper.cpp (CUDA) + transcribe/dictate
      ]
      (_: {
        enable = true;
      });

  wayland.windowManager.hyprland.extraConfig = ''
    hl.config({ input = { sensitivity = -1.0 } })
  '';

  programs.zsh.envExtra = ''
    export STARSHIP_HOST_ICON="*󰲢 "
  '';
}
