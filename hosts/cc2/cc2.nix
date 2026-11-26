{ lib, ... }:
{
  home.stateVersion = "25.05";

  myModules.bundles = {
    cli.enable = true;
    dev.enable = true;
    lab.enable = true; # gpg/pass, syncthing, AI clients, anydesk, languages
  };

  # ---------------------------------
  # Packages & apps only on this host
  # ---------------------------------

  myModules.apps =
    lib.genAttrs
      [
        "labguide" # desktop widget (list: modules/home/apps/labguide.nix)
        "pureref"
        "t3code"
        "pi" # harness
        "whisper" # whisper.cpp (CUDA) + transcribe/dictate
      ]
      (_: {
        enable = true;
      });

  # --------------------------------
  # Extra settings only on this host
  # --------------------------------

  wayland.windowManager.hyprland.extraConfig = ''
    hl.config({ input = { sensitivity = -1.0 } })
  '';

  programs.zsh.envExtra = ''
    export STARSHIP_HOST_ICON="*󰲢 "
  '';
}
