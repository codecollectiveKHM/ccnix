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

  # Hosts with myModules.system.ollama.enable pull these
  services.ollama.loadModels = [
    "llava:13b"
    "gemma4:e2b"
  ];
}
