# cc3 — lab workstation
{ pkgs, ... }:
{
  imports = [
    ./cc3-hardware.nix
    ./cc3-disko.nix
  ];
  system.stateVersion = "26.05";

  myModules.roles.workstation.enable = true;
  myModules.system = {
    nvidia.enable = true;
    alle = {
      enable = true;
      lanSsh = true;
    };
  };

  services.flatpak.enable = true; # Bottles (HM nix-flatpak)
  fonts.packages = [ pkgs.vista-fonts ]; # Calibri, Consolas, ...
}
