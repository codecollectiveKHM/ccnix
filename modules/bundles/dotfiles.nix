{ config, ... }:
let
  home = config.home.homeDirectory;
in
{
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  home.file.".scripts" = {
    source = ../../static/scripts;
    recursive = true;
    executable = true;
  };

  home.file.".local/share/fonts" = {
    source = ../../static/fonts;
    recursive = true;
  };

  # Writes user-dirs.dirs + user-dirs.conf (enabled=False) so xdg-user-dirs-update stops rewriting it
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true; # legacy default; HM 26.05 flips to false
    desktop = "${home}/Desktop";
    documents = "${home}/Documents";
    publicShare = home;
    download = home;
    templates = home;
    music = home;
    pictures = home;
    videos = home;
  };

  xdg.configFile = {
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${home}/.config/home-manager/static/nvim";
    # Apps rewrite this; force keeps HM authoritative
    "mimeapps.list" = {
      source = ../../static/mimeapps.list;
      force = true;
    };
    "browser".source = ../../static/browser; # browser dotfiles
    "gemini-rofi".source = ../../static/gemini-rofi; # rofi prompt library

    "fd/ignore".text = ''
      .local/share/Trash/
      .git/
      backups/
      vault/
      mnt/
    '';
  };
}
