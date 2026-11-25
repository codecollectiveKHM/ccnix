{
  config,
  lib,
  osConfig,
  ...
}:
{
  options.myModules.apps.ssh.enable = lib.mkEnableOption "ssh";
  config = lib.mkIf config.myModules.apps.ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          IgnoreUnknown = "GSSAPIKexAlgorithms,GSSAPIAuthentication";
          HashKnownHosts = true;
          ControlMaster = "auto";
          ControlPath = "~/.ssh/master-%C"; # %C safe variable
          ControlPersist = "10m";
        };
        "github.com" = {
          ControlMaster = "no";
        };
        # "pc" = {
        #   HostName = "pc.REDACTED.ts.net";
        #   User = "admin";
        #   RequestTTY = "force";
        # };
      }
      # Tunnel for pi's edge0-cc2 endpoint (ai-endpoints.nix): ssh -fN edge0-cc2
      // lib.optionalAttrs (!osConfig.myModules.system.edge0.enable) {
        edge0-cc2 = {
          HostName = "cc2.local";
          User = "alle";
          LocalForward = "18000 localhost:8000";
          ExitOnForwardFailure = "yes"; # fail loudly if 18000 is taken
          ControlMaster = "no"; # own process, so pkill closes it
        };
      };
    };
  };
}
