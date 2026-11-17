# Hyprland desktop apps, fonts and GUI helpers
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.bundles.desktop.enable = lib.mkEnableOption "Hyprland desktop bundle";

  config = lib.mkIf config.myModules.bundles.desktop.enable {
    myModules.apps =
      lib.genAttrs
        [
          "ags"
          "dunst"
          "firefox"
          "hyprland"
          "kanata"
          "kitty"
          "mpv"
          "plasma"
          "polkit"
          "rofi"
          "swayimg"
          "vlc"
          "waybar"
          "wlr-which-key"
          "zathura"
        ]
        (_: {
          enable = lib.mkDefault true;
        });

    home.packages = with pkgs; [
      hyprshot # screenshots
      wev # wayland event debugger
      wl-clipboard # clipboard for nvim
      corefonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.iosevka
      nerd-fonts.caskaydia-cove
      kitty # GPU accelerated
      xdg-desktop-portal-gtk # yazi as desktop portal
      xdg-desktop-portal-termfilechooser # yazi as desktop portal
      libnotify # notify-send
      socat # Hyprland IPC tracking, Bottles ags script fix
      hyprlock # lock screen
    ];

    fonts.fontconfig.enable = true;
    home.file.".local/share/fonts" = {
      source = ../../../static/fonts;
      recursive = true;
    };

    xdg.configFile = {
      "browser".source = ../../../static/browser; # browser dotfiles
      "gemini-rofi".source = ../../../static/gemini-rofi; # rofi prompt library
    };

    dconf.settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
  };
}
