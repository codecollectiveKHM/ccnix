{ config, lib, ... }:
{
  options.myModules.system.nvidia.enable =
    lib.mkEnableOption "NVIDIA proprietary driver (+ its libs for nix-ld)";

  config = lib.mkIf config.myModules.system.nvidia.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true; # Wayland, Hyprland
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true; # open kernel module (RTX 20-series+), not nouveau
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    programs.nix-ld.libraries = [ config.hardware.nvidia.package ];
  };
}
