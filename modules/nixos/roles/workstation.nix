# Lab workstation = desktop role + Plasma fallback, NDI
{ config, lib, ... }:
let
  on = lib.mkDefault true;
in
{
  options.myModules.roles.workstation.enable = lib.mkEnableOption "workstation role";

  config = lib.mkIf config.myModules.roles.workstation.enable {
    myModules.roles.desktop.enable = on;
    myModules.system = {
      desktop.plasma.enable = on;
      ndi.enable = on;
    };
  };
}
