# NDI over the LAN: OBS + DistroAV, mDNS discovery (avahi opens 5353/udp)
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.system.ndi.enable = lib.mkEnableOption "NDI (OBS + DistroAV)";

  config = lib.mkIf config.myModules.system.ndi.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true; # resolve .local
      settings.publish = {
        disable-publishing = false;
        disable-user-service-publishing = false;
        publish-addresses = true;
      };
    };

    networking.firewall.allowedTCPPortRanges = [
      {
        from = 5960;
        to = 5970;
      }
    ];

    environment.systemPackages = [
      (pkgs.wrapOBS {
        plugins = [ pkgs.obs-studio-plugins.distroav ];
      })
    ];
  };
}
