# Hyprland session (+ optional SDDM/Plasma fallback). Replaces gui-config.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.system.desktop;
in
{
  options.myModules.system.desktop = {
    enable = lib.mkEnableOption "Hyprland desktop";
    plasma.enable = lib.mkEnableOption "SDDM + Plasma 6 fallback session";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # Hyprland >= 0.57 ignores hyprland.conf and starts a generated default Lua
        # config. Fail the build instead of a bare session.
        assertions =
          let
            hm = config.home-manager.users.${config.myModules.host.user}.wayland.windowManager.hyprland;
          in
          [
            {
              assertion = hm.configType == "lua";
              message = "Hyprland >= 0.57 only reads Lua; set HM wayland.windowManager.hyprland.configType = \"lua\".";
            }
          ];

        hardware.graphics = {
          enable = true;
          enable32Bit = true; # Steam/32-bit apps
        };
        environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Electron/Chromium on Wayland

        services.xserver = {
          enable = true;
          xkb = {
            layout = "us";
            variant = "";
          };
        };

        programs.hyprland = {
          enable = true;
          xwayland.enable = true;
        };
        programs.dconf.enable = true; # the GTK portal cannot start without it
        security.pam.services.hyprlock = { }; # else hyprlock falls back to /etc/pam.d/su

        xdg.portal = {
          enable = true;
          xdgOpenUsePortal = true;
          # xdg-desktop-portal-hyprland comes from programs.hyprland (built against its package)
          extraPortals = with pkgs; [
            xdg-desktop-portal-termfilechooser
            xdg-desktop-portal-gtk
          ];
          config = {
            hyprland = {
              default = [
                "hyprland"
                "gtk"
              ];
              "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
              "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
            };
            common.default = [ "gtk" ];
          };
        };
      }
      (lib.mkIf cfg.plasma.enable {
        services.displayManager.sddm.enable = true;
        services.desktopManager.plasma6.enable = true;
      })
    ]
  );
}
