# Edge0-145B (edge0-strata on CUDA) as an on-demand system service, run as the primary user
# (the build lives in their home: ~/src/edge0, dev shell flake ~/src/edge0-env, not in this repo).
# Any local user (admin, alle) may start/stop it: systemctl start edge0 · journalctl -u edge0 -f
# Every HM user on this host gets myModules.ai.endpoints.edge0, so pi lists it.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.system.edge0;
  inherit (config.myModules.host) user;
  home = config.users.users.${user}.home;
  port = 8000;
in
{
  options.myModules.system.edge0 = {
    enable = lib.mkEnableOption "Edge0-145B server (127.0.0.1:8000)";
    vramReserveMib = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "VRAM left free beside --expert-cache auto (desktop + request graphs).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Start/stop/restart without sudo for every normal user (group users)
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "edge0.service" &&
            ["start", "stop", "restart"].indexOf(action.lookup("verb")) >= 0 &&
            subject.isInGroup("users")) {
          return polkit.Result.YES;
        }
      });
    '';

    # `edge0 start|stop|status` for users who can't read the journal
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "edge0" ''
        case "''${1:-status}" in
          start)
            systemctl start edge0 || exit 1
            echo "loading (1-2 min)..."
            until ${pkgs.curl}/bin/curl -so /dev/null localhost:${toString port}; do
              systemctl -q is-active edge0 || { echo "edge0 failed; admin: journalctl -u edge0"; exit 1; }
              sleep 3
            done
            echo "ready: pi → /model → Edge0 145B" ;;
          stop) systemctl stop edge0 ;;
          *) systemctl is-active edge0 ;;
        esac
      '')
    ];

    home-manager.sharedModules = [
      {
        myModules.ai.endpoints.edge0 = {
          baseUrl = "http://localhost:${toString port}/v1";
          models.edge0_145b = {
            name = "Edge0 145B";
            contextWindow = 131072;
          };
        };
      }
    ];

    systemd.services.edge0 = {
      description = "Edge0-145B inference server (127.0.0.1:${toString port})";
      # no wantedBy: started on demand, holds ~30 GB VRAM + 50 GB RAM only while running
      conflicts = [ "ollama.service" ]; # starting edge0 stops ollama, and vice versa
      serviceConfig = {
        User = user;
        WorkingDirectory = "${home}/src/edge0/edge0-infer";
        Environment = [ "STRATA_ENGINE_NICE=0" ];
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.nix}/bin/nix develop path:${home}/src/edge0-env --command"
          "${home}/src/edge0/edge0-infer/build/cpu/bin/edge0-infer serve"
          "--model ${home}/models/Edge0-145B-q3k --host 127.0.0.1 --port ${toString port}"
          "--model-option ple-io=ram"
          "--strata-arg --vram-reserve-mib --strata-arg ${toString cfg.vramReserveMib}"
        ];
        # + runs as root: bring ollama back once edge0 is gone
        ExecStopPost = "-+${pkgs.systemd}/bin/systemctl start --no-block ollama.service";
        Restart = "no";
        TimeoutStopSec = 60;
        LimitMEMLOCK = "infinity"; # ple-io=ram mlocks a 51 GB table
        LimitRTTIME = "infinity";

        # Sandbox (released 2026-11-12: untrusted). No PrivateDevices: it needs /dev/nvidia*.
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [
          "${home}/src/edge0"
          "${home}/.cache"
        ];
        IPAddressDeny = "any"; # loopback only: serves 127.0.0.1, can't phone home
        IPAddressAllow = "localhost";
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
