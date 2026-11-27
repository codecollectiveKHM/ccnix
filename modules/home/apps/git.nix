{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.git.enable = lib.mkEnableOption "git";
  config = lib.mkIf config.myModules.apps.git.enable {
    home.packages = with pkgs; [
      diffnav
    ];
    # identity (user.name/email) comes from each repo's modules/nixos/base/site.nix
    programs.git = {
      enable = true;
      ignores = [ ".direnv/" ];
      settings = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "nvim";
        pager = {
          diff = "diffnav";
          show = "diffnav";
          log = "diffnav";
        };
      };
      # delta.enable = true;
    };
  };
}
