{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.kitty.enable = lib.mkEnableOption "kitty";
  config = lib.mkIf config.myModules.apps.kitty.enable {
    home.packages = [ pkgs.kitty ];
    xdg.configFile."kitty".source = ../../../static/kitty;
  };
}
