# Lab stack: secrets, sync, AI clients, remote desktop, languages (ccnix only)
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.myModules.bundles.lab.enable =
    lib.mkEnableOption "lab bundle (gpg/pass, sync, AI, remote desktop, languages)";

  config = lib.mkIf config.myModules.bundles.lab.enable {
    myModules.apps = lib.mkMerge [
      (lib.genAttrs
        [
          "gpg"
          "syncthing"
          "gh-dash"
          "miniconda"
          "quarto"
          "rust"
        ]
        (_: {
          enable = lib.mkDefault true;
        })
      )
      { gpg.pinentry = lib.mkDefault pkgs.pinentry-tty; } # lab: no rofi pinentry
    ];

    # SSH keys stay with the system ssh-agent (site.nix startAgent): gpg-agent's ssh mode asks again
    # through pinentry-tty on whichever tty it last saw, so ssh and colmena hit "agent refused operation"
    services.gpg-agent.enableSshSupport = lib.mkForce false;

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
