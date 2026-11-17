{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myModules.apps.labguide;
  resolve = n: lib.getAttrFromPath (lib.splitString "." n) pkgs;
  norm =
    e:
    if builtins.isString e then
      {
        name = e;
        action = null;
        icon = null;
      }
    else
      e;
  toEntry = e: {
    inherit (e) name icon;
    desc = (resolve e.name).meta.description or "";
    exec = "${cfg.terminal} -e sh -c ${
      lib.escapeShellArg (if e.action != null then e.action else e.name)
    }";
  };
in
{
  options.myModules.apps.labguide = {
    enable = lib.mkEnableOption "labguide desktop widget";
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
      description = "Terminal used to launch curated packages";
    };
    packages = lib.mkOption {
      description = "Curated packages shown by the widget (name, or { name, action, icon }).";
      default = [
        # TUIs — run and stay
        "btop"
        "yazi"
        "lazygit"
        "dysk"
        "fish"
        "wev"

        # Search and navigation
        {
          name = "ripgrep";
          action = "man rg";
        }
        {
          name = "fd";
          action = "fd --help | less -R";
        }
        {
          name = "ast-grep";
          action = "ast-grep --help | less -R";
        }
        {
          name = "zoxide";
          action = "zoxide --help | less -R";
        }
        {
          name = "fasd";
          action = "man fasd";
        }
        {
          name = "as-tree";
          action = "as-tree --help | less -R";
        }

        # Files and text
        {
          name = "bat";
          action = "bat --help | less -R";
        }
        {
          name = "jq";
          action = "man jq";
        }
        {
          name = "pandoc";
          action = "man pandoc";
        }
        {
          name = "trash-cli";
          action = "trash --help | less -R";
        }
        {
          name = "unzip";
          action = "man unzip";
        }

        # PDF and media
        {
          name = "poppler-utils";
          action = "man pdfinfo";
        }
        {
          name = "qpdf";
          action = "man qpdf";
        }
        {
          name = "imagemagick";
          action = "magick --help | less -R";
        }
        {
          name = "chafa";
          action = "chafa --help | less -R";
        }
        {
          name = "yt-dlp";
          action = "yt-dlp --help | less -R";
        }

        # Network and remote
        {
          name = "tailscale";
          action = "tailscale status; read";
        }
        {
          name = "sshfs";
          action = "man sshfs";
        }
        {
          name = "wget";
          action = "man wget";
        }
        {
          name = "dnsutils";
          action = "man dig";
        }
        {
          name = "gh";
          action = "gh --help | less -R";
        }

        # Nix and Wayland
        {
          name = "colmena";
          action = "colmena --help | less -R";
        }
        {
          name = "statix";
          action = "statix --help | less -R";
        }
        {
          name = "hyprshot";
          action = "hyprshot --help | less -R";
        }
        {
          name = "wl-clipboard";
          action = "man wl-copy";
        }
      ];
      type =
        with lib.types;
        listOf (
          either str (submodule {
            options = {
              name = lib.mkOption { type = str; };
              action = lib.mkOption {
                type = nullOr str;
                default = null;
              };
              icon = lib.mkOption {
                type = nullOr str;
                default = null;
              };
            };
          })
        );
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.programs.ags.enable;
        message = "labguide requires myModules.apps.ags.enable";
      }
    ];

    home.packages = [ pkgs.figlet ]; # banner pane renders the hostname at runtime

    xdg.configFile."labguide" = {
      source = ../../../static/labguide;
      recursive = true;
    };
    xdg.configFile."labguide/packages.json".text = builtins.toJSON (
      map (e: toEntry (norm e)) cfg.packages
    );

    systemd.user.services.labguide = {
      Unit = {
        Description = "AGS desktop widget";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
        StartLimitIntervalSec = 60;
        StartLimitBurst = 5;
      };
      Service = {
        ExecStart = "${config.programs.ags.finalPackage}/bin/ags -b labguide -c %h/.config/labguide/config.js";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install.WantedBy = [
        "graphical-session.target"
        "hyprland-session.target"
      ];
    };
  };
}
