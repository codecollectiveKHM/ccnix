{
  config,
  lib,
  osConfig,
  ...
}:
{
  options.myModules.apps.kanata.enable = lib.mkEnableOption "kanata" // {
    default = osConfig.myModules.system.kanata.enable; # one switch: the NixOS side (kanata)
  };
  config = lib.mkIf config.myModules.apps.kanata.enable {
    xdg.configFile."kanata".source = ../../../static/kanata;
  };
}
