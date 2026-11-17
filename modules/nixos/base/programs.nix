{ pkgs, ... }:
{
  programs.zsh.enable = true;
  services.printing.enable = true;
  environment.systemPackages = with pkgs; [
    brightnessctl
    firefox
  ];
  # Libraries for unpatched binaries once a host sets programs.nix-ld.enable
  # (nvidia libs are added by hardware/nvidia.nix)
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
  ];
}
