# Primary user from myModules.host.user; keys from lib/keys.nix.
# Password hashes are seeded at install time (commands.txt, hosts/installer).
{ config, pkgs, ... }:
let
  inherit (config.myModules.host) user;
  keys = import ../../../lib/keys.nix;
  passFile = "/etc/${user}.pass";
in
{
  users.users.${user} = {
    hashedPasswordFile = passFile;
    isNormalUser = true;
    description = user;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ]; # no "uinput": kanata's service has its own access (SupplementaryGroups)
    packages = [ pkgs.kdePackages.kate ];
    openssh.authorizedKeys.keys = keys.admins;
  };
  users.users.root = {
    hashedPasswordFile = passFile;
    openssh.authorizedKeys.keys = keys.admins;
  };
  security.sudo.wheelNeedsPassword = true;

  systemd.tmpfiles.rules = [ "d /home/${user} 0700 ${user} users - -" ];
}
