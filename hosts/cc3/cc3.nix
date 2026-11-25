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
        "t3code"
        "pi" # gemma4
      ]
      (_: {
        enable = true;
      });

  programs.zsh.envExtra = ''
    export STARSHIP_HOST_ICON="*󰲤 "
  '';
}
