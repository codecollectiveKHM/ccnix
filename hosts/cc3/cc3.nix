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
        "t3code"
        "pi" # harness
      ]
      (_: {
        enable = true;
      });

  # --------------------------------
  # Extra settings only on this host
  # --------------------------------

  programs.zsh.envExtra = ''
    export STARSHIP_HOST_ICON="*󰲤 "
  '';
}
