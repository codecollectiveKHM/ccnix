# SSH public keys: one source for authorized_keys (modules/nixos/base/users.nix)
# and agenix recipients (secrets/secrets.nix).
rec {
  users = {
    cc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9zHr4+PtAx3W18a/g96OarrbxPlh3r+4RpWLYPCWFI admin@cc1";
    cc2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZjlV5gu2Nzn8AvNJjdLRLEIx6egXDNiHZZTjJyNbl/ admin@cc2";
    dell = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObc0G/3xu6Y2sqT7peA3gJsaHEyn+Wz616kRZtNMhQV dell"; # personal laptop, other tailnet
  };
  # Devices allowed to log in as the primary user (and root) on every host
  admins = [
    users.cc1
    users.cc2 # colmena deploys from cc2
  ];

  # Shared-in devices: primary user only, on hosts with myModules.system.sharedSsh
  shared = [ users.dell ];

  # `cat /etc/ssh/ssh_host_ed25519_key.pub` on each host (agenix recipients)
  hosts = { };
}
