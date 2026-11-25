{ pkgs, ... }:
{
  programs.zsh.enable = true;
  services.printing.enable = true;
  environment.systemPackages = with pkgs; [
    brightnessctl
    firefox
  ];
  # Libraries for unpatched binaries once nix-ld is on (roles/workstation.nix or a host);
  # nvidia libs are added by hardware/nvidia.nix
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
  ];
}
