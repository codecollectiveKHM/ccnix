{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.vlc.enable = lib.mkEnableOption "vlc";
  config = lib.mkIf config.myModules.apps.vlc.enable {
    home.packages = [ pkgs.vlc ];
    # vlcrc only: vlc-qt-interface.conf is runtime state (recents), left to VLC
    xdg.configFile."vlc/vlcrc".source = ../../../static/vlc/vlcrc;
  };
}
