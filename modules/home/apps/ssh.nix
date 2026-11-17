{ config, lib, ... }:
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
        # "pc" = {
        #   HostName = "pc.tailf072cc.ts.net";
        #   User = "admin";
        #   RequestTTY = "force";
        # };
      };
    };
  };
}
