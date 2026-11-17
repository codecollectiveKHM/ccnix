{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.myModules.apps.syncthing.enable = lib.mkEnableOption "syncthing";

  config = lib.mkIf config.myModules.apps.syncthing.enable {

    home.packages = [ pkgs.syncthing ];

    services.syncthing.enable = true;
  };
}
