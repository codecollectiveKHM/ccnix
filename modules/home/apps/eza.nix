{ config, lib, ... }:
{
  options.myModules.apps.eza.enable = lib.mkEnableOption "eza";
  config = lib.mkIf config.myModules.apps.eza.enable {
    programs.eza = {
      enable = true;

      # Enables git status column and file icons
      git = true;
      icons = "auto";

      # Add any default flags you always want passed to eza
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };
  };
}
