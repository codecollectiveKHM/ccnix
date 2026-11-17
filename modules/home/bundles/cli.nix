# Shell, terminal tools and core dotfiles
{
  config,
  lib,
  pkgs,
  ...
}:
let
  home = config.home.homeDirectory;
  inherit (config.myModules.host) flakePath;
in
{
  options.myModules.bundles.cli.enable = lib.mkEnableOption "CLI bundle";

  config = lib.mkIf config.myModules.bundles.cli.enable {
    myModules.apps =
      lib.genAttrs
        [
          "direnv"
          "eza"
          "fastfetch"
          "fzf"
          "git"
          "lazygit"
          "ssh"
          "starship"
          "yazi"
          "zellij"
          "zsh"
        ]
        (_: {
          enable = lib.mkDefault true;
        });

    home.packages = with pkgs; [
      poppler-utils # pdfunite pdftoppm, pdfinfo
      qpdf # merge encrypted pdfs
      ast-grep # grep
      bat # cat w highlights & more
      btop # resource monitor
      chafa # ASCII terminal graphics
      dysk # disk utilization viewer
      fasd # pipe frecency into fzf file widget results
      fd # find
      fish # shell
      gcc # compiler dependency
      imagemagick # terminal images
      jq # json parser
      pandoc # text convert cmd
      ripgrep # search
      sshfs # mount remote dirs over ssh
      tailscale # ssh virtual network aliaser
      trash-cli # safe trash
      unzip
      wget
      zoxide # z cd command
      yt-dlp # mpv dependency
      zsh-autocomplete # zsh shell plugin
      as-tree # folder trees w fd
      gh # github CLI
      dnsutils # debugging fileshare
      ffmpeg # video tooling
      yq # cml YAML JSON XML processor
      uv # Python tooling
      # Python tooling; links zstd + aws-lc (missing from nixpkgs buildInputs)
      (pixi.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [
          zstd
          aws-lc
        ];
      }))
      python3
      xxd
      psmisc # killall, fuser, pstree
    ];

    home.file.".scripts" = {
      source = ../../../static/scripts;
      recursive = true;
      executable = true;
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
      "nvim".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/static/nvim";
      # Apps rewrite this; force keeps HM authoritative
      "mimeapps.list" = {
        source = ../../../static/mimeapps.list;
        force = true;
      };
      "fd/ignore".text = ''
        .local/share/Trash/
        .git/
        backups/
        vault/
        mnt/
      '';
    };
  };
}
