# cc2 — lab workstation on a shared NVMe (old cc2 LUKS + Ubuntu): own ESP, GRUB menu
{ lib, pkgs, ... }:
{
  imports = [ ./cc2-hardware.nix ];
  system.stateVersion = "26.05";

  myModules.roles.workstation.enable = true; # desktop+plasma, audio, kanata, ndi
  myModules.system = {
    nvidia.enable = true;
    ollama.enable = true;
    sharedSsh.enable = true; # dell (personal tailnet) → admin@cc2:2222
    alle = {
      enable = true;
      lanSsh = true;
    };
  };

  home-manager.users.alle =
    { pkgs, ... }:
    {
      home.stateVersion = "25.05";
      programs.ags.enable = true;
      myModules.apps = lib.genAttrs [ "labguide" "opencode" "pi" "plasma" "yazi" ] (_: {
        enable = true;
      });
      home.packages = with pkgs; [
        figlet
        fastfetch
        kitty
      ];
    };

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    timeout = 5;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = false;
      extraEntries = ''
        menuentry "Ubuntu" {
          insmod ext2
          search --no-floppy --fs-uuid --set=root fbd9a060-351b-446b-9121-9abc471b9bb0
          linux /boot/vmlinuz root=UUID=fbd9a060-351b-446b-9121-9abc471b9bb0 ro quiet splash
          initrd /boot/initrd.img
        }
        menuentry "Windows" {
          insmod part_gpt
          insmod fat
          search --no-floppy --fs-uuid --set=root 8206-8EAC
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
  };

  myModules.system.edge0.enable = true; # systemctl start edge0 (any user)

  services.flatpak.enable = true; # Bottles (HM nix-flatpak)
  fonts.packages = with pkgs; [
    corefonts
    vista-fonts # Calibri, Consolas, ...
  ];

  environment.systemPackages = [ pkgs.ollama ];
}
