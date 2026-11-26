{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.mpv.enable = lib.mkEnableOption "mpv";
  config = lib.mkIf config.myModules.apps.mpv.enable {
    home.packages = [
      pkgs.mpv
      pkgs.yt-dlp
      pkgs.mpv-clipboard # pkgs/mpv-clipboard.nix
    ];
    xdg.configFile."mpv".source = ../../../static/mpv;

    # Weekly cookie refresh from firefox
    systemd.user.services.yt-dlp-cookie-refresh = {
      Unit.Description = "Refresh yt-dlp cookies from Firefox";
      Service = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.local/share/yt-dlp";
        ExecStart = toString [
          "${pkgs.yt-dlp}/bin/yt-dlp"
          "--cookies-from-browser"
          "firefox"
          "--cookies"
          "%h/.local/share/yt-dlp/cookies.txt"
          "--skip-download"
          "https://www.youtube.com"
        ];
      };
    };

    systemd.user.timers.yt-dlp-cookie-refresh = {
      Unit.Description = "Refresh yt-dlp cookies weekly";
      Timer = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
