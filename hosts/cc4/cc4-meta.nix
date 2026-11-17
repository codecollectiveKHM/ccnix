# Lab workstation, RAVE. Read by lib/default.nix; the directory name is the host name.
{
  system = "x86_64-linux";
  user = "admin";

  deployment = {
    targetHost = "cc4.tail92efad.ts.net";
    targetUser = "root";
    allowLocalDeployment = true;
    tags = [
      "workstation"
      "linux"
    ];
  };
}
