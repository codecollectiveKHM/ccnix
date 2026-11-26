{
  networking = {
    networkmanager.enable = true;
    firewall.trustedInterfaces = [ "tailscale0" ];
  };

  # SSH over the tailnet only (tailscale0 is trusted), keys only
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  services.tailscale = {
    enable = true;
    openFirewall = true; # 41641/udp
    useRoutingFeatures = "client"; # also sets checkReversePath = "loose"
  };
}
