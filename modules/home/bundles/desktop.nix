# Hyprland desktop apps, fonts and GUI helpers
{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  options.myModules.bundles.desktop.enable = lib.mkEnableOption "Hyprland desktop bundle" // {
    # one switch: the NixOS side (desktop), for the primary user; lab users opt in
    default =
      osConfig.myModules.system.desktop.enable && config.home.username == config.myModules.host.user;
  };

  config = lib.mkIf config.myModules.bundles.desktop.enable {
    myModules.apps =
      lib.genAttrs
        [
          "ags"
          "dunst"
          "firefox"
          "hyprland"
          "kitty"
          "mpv"
          "rofi"
          "swayimg"
          "vlc"
          "waybar"
          "wlr-which-key"
          "yazi-portal" # NixOS yazi portal picker
          "zathura"
        ]
        (_: {
          enable = lib.mkDefault true;
        });

    home.packages = with pkgs; [
      hyprshot # screenshots
      wev # wayland event debugger
      wl-clipboard # clipboard for nvim
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.iosevka
      nerd-fonts.caskaydia-cove
      maple-mono.NF
      xdg-desktop-portal-gtk # yazi as desktop portal
      xdg-desktop-portal-termfilechooser # yazi as desktop portal
      libnotify # notify-send
      socat # Hyprland IPC tracking, Bottles ags script fix
      hyprlock # lock screen
      hypridle # idle lock + DPMS, started by autostart.lua
      hyprpaper # wallpaper, started by autostart.lua
    ];

    fonts.fontconfig.enable = true;
    home.file.".local/share/fonts" = {
      source = ../../../static/fonts;
      recursive = true;
    };

    xdg.configFile = {
      "browser".source = ../../../static/browser;
      "gemini-rofi".source = ../../../static/gemini-rofi;
    };

    dconf.settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
  };
}
