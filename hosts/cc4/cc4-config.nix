# cc4 — lab workstation, RAVE
{ pkgs, ... }:
{
  imports = [ ./cc4-hardware.nix ];
  system.stateVersion = "26.05";

  myModules.roles.workstation.enable = true; # desktop+plasma, audio, kanata, ndi
  myModules.system = {
    nvidia.enable = true;
    rave = {
      enable = true;
      torchSpec = ">=2.7";
      torchBackend = "cu128";
    };
    alle.enable = true; # no Home Manager config
  };

  # Early KMS (framebuffer console on the NVIDIA card)
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  services.flatpak.enable = true; # Bottles (HM nix-flatpak)
  fonts.packages = with pkgs; [
    corefonts
    vista-fonts # Calibri, Consolas, ...
  ];
}
