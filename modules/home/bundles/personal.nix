# Personal stack: secrets, sync, AI clients, remote desktop
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.myModules.bundles.personal.enable =
    lib.mkEnableOption "personal bundle (gpg/pass, sync, AI, remote desktop)";

  config = lib.mkIf config.myModules.bundles.personal.enable {
    myModules.apps =
      lib.genAttrs
        [
          "gpg"
          "syncthing"
        ]
        (_: {
          enable = lib.mkDefault true;
        });

    home.packages = with pkgs; [
      inputs.nix-claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default # llm agent cli
      jan # llm manager
      calibre # ebook-convert
      # remote working
      (anydesk.overrideAttrs (old: {
        src = fetchurl {
          inherit (old.src) urls;
          hash = "sha256-zS5P2eyTHZY7cBW8mQ2Q6M0lXcx9VZZTtpG3Bb6u7IQ=";
        };
      }))
    ];
  };
}
