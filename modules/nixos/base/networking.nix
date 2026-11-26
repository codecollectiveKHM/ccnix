{
  networking = {
    networkmanager.enable = true;
    firewall.trustedInterfaces = [ "tailscale0" ];
  };

  # Key-only SSH over the tailnet (tailscale0 is trusted); :22 on the LAN comes from alle.lanSsh (all hosts)
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  programs.ssh.startAgent = true;
  services.tailscale = {
    enable = true;
    openFirewall = true; # 41641/udp
    useRoutingFeatures = "client"; # also sets checkReversePath = "loose"
    extraSetFlags = [ "--ssh" ];
  };
}
