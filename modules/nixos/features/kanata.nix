{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.system.kanata = {
    enable = lib.mkEnableOption "kanata key remapper (system service)";
    devices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/dev/input/by-id/usb-CHERRY_CHERRY_Wireless_Device-event-kbd" ];
      description = "Keyboards to grab; [ ] = every keyboard (laptops).";
    };
  };

  config = lib.mkIf config.myModules.system.kanata.enable {
    services.kanata = {
      enable = true;
      package = pkgs.kanata.override { withCmd = true; };
      keyboards.default = {
        inherit (config.myModules.system.kanata) devices;
        configFile = ../../../static/kanata/config-nixos.kbd;
        port = 10000; # TCP for hyprkan; module sets the matching network sandbox
      };
    };
  };
}
