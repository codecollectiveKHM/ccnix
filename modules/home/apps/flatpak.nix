{
  config,
  lib,
  osConfig,
  ...
}:

{
  options.myModules.apps.flatpak.enable = lib.mkEnableOption "flatpak apps" // {
    # one switch: the NixOS side (services.flatpak), for the primary user; lab users opt in
    default = osConfig.services.flatpak.enable && config.home.username == config.myModules.host.user;
  };

  config = lib.mkIf config.myModules.apps.flatpak.enable {

    services.flatpak = {
      enable = true;
      uninstallUnmanaged = true;

      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];

      # packages: base/site.nix (every flatpak host of the repo) + the host file

      update.auto = {
        enable = true;
        onCalendar = "weekly"; # Prevents it from slowing down every single boot
      };
    };

    # If you ever need to alias a flatpak command to your shell, do it here.
    # programs.zsh.shellAliases = {
    #   freecad = "flatpak run org.freecad.FreeCAD";
    # };
  };
}
