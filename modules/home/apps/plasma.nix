{ config, lib, ... }:
{
  options.myModules.apps.plasma.enable = lib.mkEnableOption "plasma";
  config = lib.mkIf config.myModules.apps.plasma.enable {
    xdg.configFile."kxkbrc".text = ''
      [Layout]
      Use=true
      LayoutList=us,de
    '';
  };
}
