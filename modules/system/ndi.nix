{ pkgs, ... }:
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    settings.publish = {
      disable-publishing = false;
      disable-user-service-publishing = false;
      publish-addresses = true;
    };
  };

  environment.systemPackages = with pkgs; [
    (wrapOBS {
      plugins = [
        obs-studio-plugins.distroav
      ];
    })
  ];
}
