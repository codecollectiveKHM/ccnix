{ config, lib, ... }:
{
  options.myModules.apps.ssh.enable = lib.mkEnableOption "ssh";
  config = lib.mkIf config.myModules.apps.ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          hashKnownHosts = true;
          extraOptions = {
            IgnoreUnknown = "GSSAPIKexAlgorithms,GSSAPIAuthentication";
            ControlMaster = "auto";
            # ControlPath = "~/.ssh/%r@%h:%p";
            ControlPath = "~/.ssh/master-%C"; # %C safe variable
            ControlPersist = "10m";
          };
        };
        "imac" = {
          hostname = "imac.REDACTED.ts.net";
          user = "mar";
          extraOptions = {
            RequestTTY = "force";
          };
        };
        "nixos" = {
          hostname = "nixos.REDACTED.ts.net";
          user = "mar";
          extraOptions = {
            RequestTTY = "force";
          };
        };
        "fedora" = {
          hostname = "fedora.REDACTED.ts.net";
          user = "mar";
          extraOptions = {
            RequestTTY = "force"; # This is crucial for the v fzf function
            # RemoteCommand = "zellij attach --create fedora";
          };
        };
      };
    };
  };
}
