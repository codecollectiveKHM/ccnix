# cc4 — lab workstation, RAVE
{ pkgs, ... }:
{
  imports = [ ./cc4-hardware.nix ];
  system.stateVersion = "26.05";

  myModules.roles.workstation.enable = true; # desktop+plasma, audio, kanata, ndi
  myModules.system = {
    nvidia.enable = true;
    ollama.enable = true;
    rave = {
      enable = true;
      torchSpec = ">=2.7";
      torchBackend = "cu128";
    };
    alle = {
      enable = true;
      lanSsh = true;
    };
  };

  home-manager.users.alle = {
    home.stateVersion = "25.05";
    myModules.bundles.desktop.enable = true; # apps.hyprland → ~/.config/hypr
    myModules.apps.pi.enable = true;
    # Same as admin (cc4.nix); NVIDIA env comes from hardware/nvidia.nix
    wayland.windowManager.hyprland.extraConfig = ''
      hl.config({
        input  = { sensitivity = -1.0 },
        cursor = { no_hardware_cursors = true },
      })
    '';
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
