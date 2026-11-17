# Physically used machine: Hyprland, audio, key remapping
{ config, lib, ... }:
{
  options.myModules.roles.desktop.enable = lib.mkEnableOption "desktop role";

  config.myModules.system = lib.mkIf config.myModules.roles.desktop.enable (
    lib.genAttrs [ "desktop" "audio" "kanata" ] (_: {
      enable = lib.mkDefault true;
    })
  );
}
