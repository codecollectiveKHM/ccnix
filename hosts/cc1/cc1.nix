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
        "labguide" # desktop widget (list: modules/home/apps/labguide.nix)
        "t3code"
        "opencode"
        "pi" # gemma4
      ]
      (_: {
        enable = true;
      });

  home.sessionVariables = {
    # Specify NVIDIA as the backend for various libraries
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland"; # Force Wayland for various toolkits
    XDG_CURRENT_DESKTOP = "hyprland"; # Portal variables
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      hl.config({ input = { sensitivity = -1.0 } })
    '';
  };

  # Per host extra configurations
  programs = {
    zsh.envExtra = ''
      export STARSHIP_HOST_ICON="*󰲠 "
    '';
    zsh.shellAliases = {
      # Rebuild the system flake
      ns = "cd ~/.config/home-manager && ./static/scripts/readme-tree-update.sh && git add -A && sudo nixos-rebuild switch --flake .#cc1 && cd -";
      nd = "zellij delete-session 'cc1' --force";
    };
  };
}
