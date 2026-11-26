# Primary user from myModules.host.user; keys from lib/keys.nix
{ config, pkgs, ... }:
let
  inherit (config.myModules.host) user;
  keys = import ../../../lib/keys.nix;
in
{
  users.users.${user} = {
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
  users.users.root.openssh.authorizedKeys.keys = keys.admins;
  systemd.tmpfiles.rules = [ "d /home/${user} 0700 ${user} users - -" ];
}
