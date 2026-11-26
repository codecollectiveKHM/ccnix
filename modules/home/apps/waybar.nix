{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  # VeraCrypt vault widget only where the vault exists
  vault = osConfig.myModules.system.veracrypt.enable or false;
  bluetooth = osConfig.hardware.bluetooth.enable;
in
{
  options.myModules.apps.waybar.enable = lib.mkEnableOption "waybar";
  config = lib.mkIf config.myModules.apps.waybar.enable {
    home.packages = lib.optional bluetooth pkgs.overskride; # bluetooth widget on-click
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          position = "top";
          layer = "top";
          exclusive = false;
          height = 49;
          "margin-left" = 5;
          "margin-right" = 5;
          spacing = 4;

          include = [
            "~/.config/waybar/modules.json"
          ];

          modules-left = [
            "hyprland/window"
          ];

          modules-center = [
            "hyprland/workspaces"
          ];

          modules-right = [
            "pulseaudio"
            "network"
          ]
          ++ lib.optional bluetooth "bluetooth"
          ++ [ "tray" ]
          ++ lib.optional vault "custom/vault"
          ++ [
            "battery"
            "clock"
          ];
        };
      };
    };

    # Mix static modules.json and other files with the declarative config above
    xdg.configFile."waybar" = {
      source = ../../../static/waybar;
      recursive = true;
    };
  };
}
