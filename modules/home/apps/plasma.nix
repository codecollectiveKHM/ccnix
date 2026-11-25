{
  config,
  lib,
  osConfig,
  ...
}:
{
  options.myModules.apps.plasma.enable = lib.mkEnableOption "plasma" // {
    default = osConfig.myModules.system.desktop.plasma.enable; # one switch: the NixOS side (desktop.plasma)
  };
  config = lib.mkIf config.myModules.apps.plasma.enable {
    xdg.configFile."kxkbrc".text = ''
      [Layout]
      Use=true
      LayoutList=us,de
    '';
  };
}
