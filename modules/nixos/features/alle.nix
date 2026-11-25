# alle — shared lab account. Its Home Manager setup stays in each host's
# <h>-config.nix (home-manager.users.alle); modules/home is already loaded for it.
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
