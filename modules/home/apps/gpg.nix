{
  config,
  lib,
  pkgs,
  ...
}:

let
  # rofi by default (espanso, nvim have no tty); tty when the caller sets PINENTRY_USER_DATA=tty
  pinentry-auto = pkgs.writeShellScriptBin "pinentry-auto" ''
    [ "''${PINENTRY_USER_DATA-}" = tty ] && exec ${lib.getExe pkgs.pinentry-tty} "$@"
    exec ${lib.getExe pkgs.pinentry-rofi} "$@"
  '';
in
{
  options.myModules.apps.gpg = {
    enable = lib.mkEnableOption "gpg";
    pinentry = lib.mkOption {
      type = lib.types.package;
      default = pinentry-auto;
    };
  };

  config = lib.mkIf config.myModules.apps.gpg.enable {

    home.packages = with pkgs; [
      pass
    ];

    programs.gpg = {
      enable = true;
      homedir = "${config.home.homeDirectory}/.local/share/gnupg"; # HM exports GNUPGHOME from this
    };

    services.gpg-agent = {
      enable = true;
      pinentry.package = config.myModules.apps.gpg.pinentry;

      # Keep the vault unlocked in RAM for 1 hour (3600 seconds) after initial unlock
      defaultCacheTtl = 3600;

      # Maximum time before a forced re-prompt, regardless of recent activity (24 hours)
      maxCacheTtl = 86400;

      # Optional: Enable SSH support to allow using GPG keys for SSH authentication
      # if you decide to consolidate your cryptographic keys in the future.
      enableSshSupport = true;
    };
  };
}
