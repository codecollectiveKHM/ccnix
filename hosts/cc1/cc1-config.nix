# cc1 — lab workstation: ComfyUI, JupyterHub, RAVE
{ pkgs, ... }:
{
  imports = [
    ./cc1-hardware.nix
    ./cc1-disko.nix
  ];
  system.stateVersion = "26.05";

  myModules.roles.workstation.enable = true; # desktop+plasma, audio, kanata, ndi
  myModules.system = {
    nvidia.enable = true;
    ollama.enable = true;
    sharedSsh.enable = true; # dell (personal tailnet) → admin@cc1:2222
    # edge0.enable = true; # once ~/src/edge0 + ~/models are in place (docs/EDGE0.md)
    comfyui = {
      enable = true;
      tailscaleServe = true;
    };
    jupyterhub.enable = true;
    rave = {
      enable = true;
      torchSpec = ">=2.7";
      torchBackend = "cu128";
    };
    alle = {
      enable = true;
      shell = pkgs.zsh;
      lanSsh = true;
    };
  };

  # alle: full CLI + desktop package set, only these app configs
  home-manager.users.alle =
    { lib, ... }:
    {
      home.stateVersion = "25.05";
      programs.ags.enable = true;
      myModules.bundles = {
        cli.enable = true;
        desktop.enable = true;
        dev.enable = true;
        personal.enable = true;
      };
      myModules.apps = lib.mkMerge [
        (lib.genAttrs [ "labguide" "opencode" "pi" "t3code" ] (_: {
          enable = true;
        }))
        # Bundle apps alle opts out of (keeps fzf git kitty lazygit ssh starship zsh)
        (lib.genAttrs
          [
            "direnv"
            "eza"
            "fastfetch"
            "yazi"
            "zellij"
            "ags"
            "dunst"
            "firefox"
            "hyprland"
            "kanata"
            "mpv"
            "plasma"
            "polkit"
            "rofi"
            "swayimg"
            "vlc"
            "waybar"
            "wlr-which-key"
            "zathura"
            "gh-dash"
            "miniconda"
            "quarto"
            "rust"
            "gpg"
            "syncthing"
          ]
          (_: {
            enable = false;
          })
        )
      ];
    };

  # Run unpatched binaries (CUDA/audio wheels)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      cudaPackages.cudatoolkit
      cudaPackages.cudnn
      ffmpeg
      libsndfile
    ];
  };

  services.flatpak.enable = true; # Bottles (HM nix-flatpak)
  fonts.packages = with pkgs; [
    corefonts
    vista-fonts # Calibri, Consolas, ...
  ];

  environment.systemPackages = with pkgs; [
    ollama
    google-chrome
    vlc
    libreoffice
    blender
    reaper
    davinci-resolve
    arduino
    processing
    puredata
    audacity
    bitwig-studio
    supercollider-with-sc3-plugins
  ];
}
