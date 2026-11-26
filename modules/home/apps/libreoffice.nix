{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.libreoffice.enable = lib.mkEnableOption "libreoffice";
  config = lib.mkIf config.myModules.apps.libreoffice.enable {
    home.packages = [
      pkgs.libreoffice
      pkgs.jre_minimal
    ];
  };
}
