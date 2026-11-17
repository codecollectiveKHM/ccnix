# Key-only sshd on :2222 for keys.shared: devices on another tailnet this host is shared into
# (Tailscale node share). Tailscale SSH (--ssh) owns :22 on the tailnet IP and denies
# shared-in users. Shares are quarantined: this host can't open connections back to them.
{ config, lib, ... }:
{
  options.myModules.system.sharedSsh.enable = lib.mkEnableOption "sshd :2222 for keys.shared";

  config = lib.mkIf config.myModules.system.sharedSsh.enable {
    users.users.${config.myModules.host.user}.openssh.authorizedKeys.keys =
      (import ../../../lib/keys.nix).shared;
    services.openssh.ports = [
      22
      2222
    ];
  };
}
