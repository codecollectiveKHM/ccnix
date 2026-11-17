{
  networking = {
    networkmanager.enable = true;
    firewall = {
      trustedInterfaces = [ "tailscale0" ];
      interfaces."tailscale0".allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [
        41641 # tailscale
        5353 # NDI Avahi
      ];
      allowedTCPPortRanges = [
        {
          from = 5960;
          to = 5970;
        }
      ]; # NDI Avahi
      checkReversePath = "loose";
    };
  };

  # Key-only SSH, reachable over the tailnet
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  programs.ssh.startAgent = true;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraSetFlags = [ "--ssh" ];
  };
}
