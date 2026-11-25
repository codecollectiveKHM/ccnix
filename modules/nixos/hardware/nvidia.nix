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
    # Prebuilt CUDA packages (ollama-cuda, whisper-cpp+CUDA, ...): unfree, so absent
    # from cache.nixos.org and otherwise compiled locally on every nixpkgs bump.
    # Key: wiki.nixos.org/wiki/CUDA. Merged before cache.nixos.org (mkAfter upstream).
    nix.settings = {
      substituters = [ "https://cache.nixos-cuda.org" ];
      trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
    };
    programs.nix-ld.libraries = [ config.hardware.nvidia.package ];
  };
}
