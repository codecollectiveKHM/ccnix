{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.pureref.enable = lib.mkEnableOption "pureref";
  config = lib.mkIf config.myModules.apps.pureref.enable {
    home.packages = [ pkgs.pureref-bin ]; # pkgs/pureref-bin.nix
  };
}
