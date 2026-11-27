# Lab-wide settings (ccnix only): what the shared modules leave to each repo
{ config, ... }:
let
  inherit (config.myModules.host) user;
  passFile = "/etc/${user}.pass"; # hash seeded at install time (commands.txt, hosts/installer)
in
{
  users.users.${user}.hashedPasswordFile = passFile;
  users.users.root.hashedPasswordFile = passFile;

  programs.ssh.startAgent = true;
  # Tailscale SSH on :22 over the tailnet; :22 on the LAN comes from alle.lanSsh
  services.tailscale.extraSetFlags = [ "--ssh" ];

  home-manager.sharedModules = [
    # Git identity for the primary user only: alle is shared by lab users
    (
      { config, lib, ... }:
      {
        programs.git.settings.user = lib.mkIf (config.home.username == user) {
          name = "paramuno";
          email = "wooxgfx@gmail.com";
        };
      }
    )
    {
      # Lab LAN consumers tunnel in as alle (alle.lanSsh). Local 18000+, not 8000: cc1's JupyterHub holds it
      myModules.ai.edge0Servers = {
        cc1 = {
          sshHost = "cc1.local";
          sshUser = "alle";
          localPort = 18001;
        };
        cc2 = {
          sshHost = "cc2.local";
          sshUser = "alle";
          localPort = 18000;
        };
      };
      # Every flatpak host (apps/flatpak.nix); a host's own list adds to it
      services.flatpak.packages = [
        "com.usebottles.bottles"
        "com.github.tchx84.Flatseal"
        "com.bambulab.BambuStudio"
        "org.freecad.FreeCAD"
      ];
      # This repo's ~/.scripts and fonts (not in nix-core)
      myModules.bundles.cli.scriptsDir = ../../../static/scripts;
      myModules.bundles.desktop.fontsDir = ../../../static/fonts;
    }
  ];

  # Hosts with myModules.system.ollama.enable pull these
  services.ollama.loadModels = [
    "llava:13b"
    "gemma4:e2b"
  ];
}
