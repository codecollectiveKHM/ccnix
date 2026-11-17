# Editor toolchain (nvim LSPs/treesitter), languages and deployment tools
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.myModules.bundles.dev.enable = lib.mkEnableOption "dev bundle";

  config = lib.mkIf config.myModules.bundles.dev.enable {
    myModules.apps =
      lib.genAttrs
        [
          "gh-dash"
          "miniconda"
          "quarto"
          "rust"
        ]
        (_: {
          enable = lib.mkDefault true;
        });

    home.packages = with pkgs; [
      statix # nvim linter
      inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena # matches flake's colmenaHive
      neovim
      tree-sitter # nvim-treesitter compilation
      nodejs # nvim-treesitter compilation
      gnumake
      nil # nil_ls
      nixfmt
    ];
  };
}
