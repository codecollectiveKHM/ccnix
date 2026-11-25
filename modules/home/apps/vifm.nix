{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.vifm.enable = lib.mkEnableOption "vifm";
  config = lib.mkIf config.myModules.apps.vifm.enable {
    home.packages = [ pkgs.vifm ];
    # recursive: ~/.config/vifm stays writable, so vifm keeps vifminfo.json (history, marks) locally, out of git
    xdg.configFile."vifm" = {
      source = ../../../static/vifm;
      recursive = true;
    };
  };
}
