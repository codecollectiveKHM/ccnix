# JupyterHub with PAM logins and one systemd unit per user
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.system.jupyterhub;
  pyList = users: "{${lib.concatMapStringsSep ", " (u: "'${u}'") users}}";
  kernelEnv = pkgs.python3.withPackages (p: [
    p.ipykernel
    p.numpy
    p.pandas
    p.matplotlib
  ]);
in
{
  options.myModules.system.jupyterhub = {
    enable = lib.mkEnableOption "JupyterHub on 127.0.0.1:8000";
    admins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "alle" ];
      description = "PAM logins allowed to reach the hub (all are hub admins).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jupyterhub = {
      enable = true;
      host = "127.0.0.1"; # reach it via SSH tunnel over tailscale
      port = 8000;
      authentication = "jupyterhub.auth.PAMAuthenticator";
      spawner = "systemdspawner.SystemdSpawner"; # one systemd unit per user

      kernels.python3 = {
        displayName = "Python 3";
        language = "python";
        argv = [
          "${kernelEnv}/bin/python"
          "-m"
          "ipykernel_launcher"
          "-f"
          "{connection_file}"
        ];
        logo32 = "${kernelEnv}/${kernelEnv.sitePackages}/ipykernel/resources/logo-32x32.png";
        logo64 = "${kernelEnv}/${kernelEnv.sitePackages}/ipykernel/resources/logo-64x64.png";
      };

      extraConfig = ''
        c.Authenticator.allowed_users = ${pyList cfg.admins}
        c.Authenticator.admin_users = ${pyList cfg.admins}
        c.SystemdSpawner.mem_limit = '8G'
        c.SystemdSpawner.dynamic_users = False
      '';
    };
  };
}
