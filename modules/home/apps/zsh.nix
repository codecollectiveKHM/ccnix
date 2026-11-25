{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.myModules.host) name user flakePath;
in
{
  options.myModules.apps.zsh.enable = lib.mkEnableOption "zsh";
  config = lib.mkIf config.myModules.apps.zsh.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";

      history = {
        path = "${config.xdg.configHome}/zsh/history";
        size = 50000;
        save = 50000;
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "fasd"
        ];
        theme = "";
      };

      syntaxHighlighting.enable = true;

      # hm-session-vars.sh is sourced by HM's own .zshenv
      initContent = ''
        source "$HOME/.config/shell/init.zsh"

        # Load zsh-autocomplete LAST to ensure it hooks everything correctly
        source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

        # Reclaim Up/Down arrows from zsh-autocomplete (CSI and application mode)
        bindkey '^[[A' up-line-or-search
        bindkey '^[OA' up-line-or-search
        bindkey '^[[B' down-line-or-search
        bindkey '^[OB' down-line-or-search

        # Reclaim <C-s> from autocomplete
        bindkey '^S' fzf-history-widget

        # Reclaim these fasd bindings, this removes the Alt-l closing shell bug
        bindkey -r '^[l' '^[j' '^[k' '^[h'
      '';

      shellAliases = {
        nd = "zellij delete-session '${name}' --force";
      }
      # Rebuild this host (regenerates docs/TREE.md, stages everything): primary user's checkout + sudo
      // lib.optionalAttrs (config.home.username == user) {
        ns = "cd ${flakePath} && ./static/scripts/readme-tree-update.sh && git add -A && sudo nixos-rebuild switch --flake .#${name} && cd -";
      };
    };

    # nix config > .zshenv > .zshrc > shell/init.zsh > modules.zsh
    xdg.configFile."shell".source = ../../../static/shell;
  };
}
