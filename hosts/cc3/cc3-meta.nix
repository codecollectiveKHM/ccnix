# Lab workstation. Read by lib/default.nix; the directory name is the host name.
{
  system = "x86_64-linux";
  user = "admin";

  deployment = {
    targetUser = "root";
    allowLocalDeployment = true;
    tags = [
      "workstation"
    ];
  };
}
