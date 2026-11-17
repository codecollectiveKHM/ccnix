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
  };

  config = lib.mkIf cfg.enable {
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
