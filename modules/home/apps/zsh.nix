{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (config.myModules.host) name user flakePath;
  vc = "/run/current-system/sw/bin/veracrypt";
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

      oh-my-zsh = {
        enable = true;
        plugins = [
          "fasd"
        ];
        theme = "";
      };

      syntaxHighlighting.enable = true;
      history.path = "${config.xdg.stateHome}/zsh-history/.zsh_history"; # HM creates the dir

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
      }
      # VeraCrypt vault (pass → sudo rule in modules/nixos/features/veracrypt.nix; argv must match it)
      // lib.optionalAttrs (osConfig.myModules.system.veracrypt.enable or false) {
        obmount = "pass show obsidian-vault | sudo -n ${vc} --text --non-interactive --stdin --fs-options=nosuid,nodev --mount $HOME/.local/share/vault_container.md $HOME/vault && setsid -f obsidian >/dev/null 2>&1";
        obunmount = "sudo -n ${vc} -t -d";
      };
    };

    # nix config > .zshenv > .zshrc > shell/init.zsh > modules.zsh
    xdg.configFile."shell".source = ../../../static/shell;
  };
}
