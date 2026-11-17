{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.t3code.enable = lib.mkEnableOption "t3code";
  config = lib.mkIf config.myModules.apps.t3code.enable {
    home.packages = pkgs.t3code-bin.parts; # pkgs/t3code-bin.nix
  };
}
