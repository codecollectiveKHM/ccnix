{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  options.myModules.apps.polkit.enable = lib.mkEnableOption "polkit authentication agent" // {
    default = osConfig.myModules.system.desktop.enable; # one switch: the NixOS side (Hyprland desktop)
  };

  config = lib.mkIf config.myModules.apps.polkit.enable {

    # Hyprland only: hyprland-session.target (HM) never starts under Plasma, which has its own agent
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "Polkit GNOME Authentication Agent";
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}
