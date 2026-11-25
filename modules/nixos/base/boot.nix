{ lib, pkgs, ... }:
{
  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.editor = false; # no init=/bin/sh from the boot menu
    loader.systemd-boot.configurationLimit = lib.mkDefault 10; # ESP space
    loader.grub.configurationLimit = lib.mkDefault 10; # same for GRUB hosts (cc2)
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
