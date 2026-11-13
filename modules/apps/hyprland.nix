{ config, lib, isNixOS, ... }:
{
  options.myModules.apps.hyprland.enable = lib.mkEnableOption "hyprland";
  config = lib.mkIf config.myModules.apps.hyprland.enable (lib.mkMerge [
    {
      xdg.configFile."hypr" = {
        source = ../../static/hypr;
        recursive = true;
      };
    }

    # Hyprland >= 0.57 only reads hyprland.lua
    (lib.mkIf isNixOS {
      wayland.windowManager.hyprland = {
        configType = "lua";
        systemd.variables = [ "--all" ]; # was exec-once dbus-update-activation-environment --systemd --all
        # Written to hypr/sources.lua and required with ~/.config/hypr on package.path
        extraLuaFiles.sources.content = ../../static/hypr-choose/sources-nixos.lua;
      };
    })

    # Fedora: COPR Hyprland, legacy hyprlang config
    (lib.mkIf (!isNixOS) {
      xdg.configFile."hypr/sources.conf".source = ../../static/hypr-choose/sources-fedora.conf;
    })
  ]);
}
