# Base ssh client config; each repo adds its hosts (base/site.nix), edge0 tunnels come from ai-endpoints.nix
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
        "github.com" = {
          ControlMaster = "no";
        };
      };
    };
  };
}
