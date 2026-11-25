# cc3 — lab workstation
{ pkgs, ... }:
{
  imports = [
    ./cc3-hardware.nix
    ./cc3-disko.nix
  ];
  system.stateVersion = "26.05";

  myModules.roles.workstation.enable = true; # desktop+plasma, audio, kanata, ndi
  myModules.system = {
    nvidia.enable = true;
    alle = {
      enable = true; # no Home Manager config
      lanSsh = true;
    };
  };

  services.flatpak.enable = true; # Bottles (HM nix-flatpak)
  fonts.packages = with pkgs; [
    corefonts
    vista-fonts # Calibri, Consolas, ...
  ];
}
