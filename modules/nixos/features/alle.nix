# alle — shared lab account. Gets modules/home like every HM user (session defaults:
# plasma, polkit, kanata); extra apps go in each host's <h>-config.nix (home-manager.users.alle).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.system.alle;
in
{
  options.myModules.system.alle = {
    enable = lib.mkEnableOption "the alle lab user";
    shell = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bash;
      description = "Login shell.";
    };
    lanSsh = lib.mkEnableOption "password SSH for alle from private (LAN) addresses";
  };

  config = lib.mkIf cfg.enable {
    # Base SSH is key-only; tailnet (100.64/10) and public addresses stay key-only.
    services.openssh.extraConfig = lib.mkIf cfg.lanSsh ''
      Match User alle Address 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
        PasswordAuthentication yes
    '';
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.lanSsh [ 22 ]; # base keeps sshd tailnet-only
    # nixpkgs drops pam_unix from sshd's auth stack when PasswordAuthentication is globally off
    security.pam.services.sshd.unixAuth = lib.mkIf cfg.lanSsh (lib.mkForce true);
    # Password SSH from the LAN invites guessing: ban an address after 5 failures (10 min, longer for
    # repeat offenders). The tailnet is exempt: key-only, and colmena deploys from it.
    services.fail2ban = lib.mkIf cfg.lanSsh {
      enable = true;
      maxretry = 5;
      ignoreIP = [ "100.64.0.0/10" ];
      bantime-increment.enable = true;
    };

    home-manager.users.alle.home.stateVersion = lib.mkDefault "25.05";

    users.users.alle = {
      isNormalUser = true;
      description = "alle";
      hashedPasswordFile = "/etc/alle.pass"; # seeded at install (commands.txt)
      inherit (cfg) shell;
      home = "/home/alle";
      createHome = true;
      extraGroups = [
        "networkmanager"
        "video"
        "audio"
      ];
    };
  };
}
