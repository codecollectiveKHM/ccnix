# Edge0-145B (edge0-strata on CUDA) as an on-demand user unit for the primary user.
# Server only: clients find it via myModules.ai.endpoints.edge0 (HM, per host).
# Built by hand in ~/src/edge0 with the dev shell flake ~/src/edge0-env (not in this repo).
# Start: systemctl --user start edge0 · logs: journalctl --user -u edge0 -f
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.system.edge0;
  inherit (config.myModules.host) user;
  systemctl = "${pkgs.systemd}/bin/systemctl";
in
{
  options.myModules.system.edge0 = {
    enable = lib.mkEnableOption "Edge0-145B user unit (127.0.0.1:8000)";
    vramReserveMib = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "VRAM left free beside --expert-cache auto (desktop + request graphs).";
    };
  };

  config = lib.mkIf cfg.enable {
    # ple-io=ram mlocks a 51 GB table; user units can't exceed their manager's limit
    systemd.services."user@".serviceConfig.LimitMEMLOCK = "infinity";

    # Let the unit stop/start the system ollama (a user unit can't Conflicts= a system one)
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "ollama.service" &&
            subject.user == "${user}") {
          return polkit.Result.YES;
        }
      });
    '';

    systemd.user.services.edge0 = {
      description = "Edge0-145B inference server (127.0.0.1:8000)";
      unitConfig.ConditionUser = user;
      # no wantedBy: started by hand, holds ~30 GB VRAM + 50 GB RAM only while running
      serviceConfig = {
        WorkingDirectory = "%h/src/edge0/edge0-infer";
        Environment = [ "STRATA_ENGINE_NICE=0" ];
        ExecStartPre = "-${systemctl} stop ollama.service";
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.nix}/bin/nix develop path:%h/src/edge0-env --command"
          "%h/src/edge0/edge0-infer/build/cpu/bin/edge0-infer serve"
          "--model %h/models/Edge0-145B-q3k --host 127.0.0.1 --port 8000"
          "--model-option ple-io=ram"
          "--strata-arg --vram-reserve-mib --strata-arg ${toString cfg.vramReserveMib}"
        ];
        ExecStopPost = "-${systemctl} start ollama.service";
        Restart = "no";
        TimeoutStopSec = 60;
        LimitMEMLOCK = "infinity";
        LimitRTTIME = "infinity";

        # Sandbox (released 2026-11-12: untrusted). No PrivateDevices: it needs /dev/nvidia*.
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [
          "%h/src/edge0"
          "%h/.cache"
        ];
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        LockPersonality = true;
        SystemCallArchitectures = "native";
      };
    };
  };
}
