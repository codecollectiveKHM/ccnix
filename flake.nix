{
  description = "Code Collective lab: NixOS + Home Manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest"; # Declarative partition modification & mounting
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest"; # flatpacks
    agenix.url = "github:ryantm/agenix"; # agenix secrets colmena
    colmena = {
      url = "github:zhaofengli/colmena"; # CLI + lib.makeHive from one source
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.stable.follows = "nixpkgs";
    };

    # Particular sources
    ags.url = "github:Aylur/ags/v1";
    nix-claude-code.url = "github:ryoppippi/nix-claude-code";
    opencode.url = "github:anomalyco/opencode";
    zjstatus.url = "github:dj95/zjstatus";
    comfyui-nix.url = "github:utensils/comfyui-nix";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs ({ inherit system; } // hosts.nixpkgsArgs);
      hosts = import ./lib { inherit inputs; };
    in
    {
      # `direnv allow` / `nix develop`: editor tooling for this repo only
      devShells.${system}.default = pkgs.mkShell {
        name = "dotfiles-shell";
        packages = with pkgs; [
          tree-sitter
          nil # Nix
          nixfmt
          kdlfmt
          statix
          deadnix
          lua-language-server # Lua
          stylua
          vscode-langservers-extracted # JSON / YAML / HTML
          yaml-language-server
          marksman # markdown
          taplo # TOML
          bash-language-server # Bash / Shell scripts
          shfmt
          prettier # Generic formatters
          gitleaks # .githooks/pre-commit
          fd # static/scripts/readme-tree-update.sh
          as-tree
        ];
        shellHook = ''
          [ "$(git config core.hooksPath)" = .githooks ] ||
            echo "hint: git config core.hooksPath .githooks  # gitleaks + nixfmt pre-commit"
        '';
      };

      # `nix fmt`
      formatter.${system} = pkgs.nixfmt-tree;

      # `nix flake check`: lint, format, secret scan, Hyprland config.
      # (nixosConfigurations are evaluated by flake check itself.)
      checks.${system} =
        let
          src = ./.;
          run =
            name: inputs: cmd:
            pkgs.runCommand "check-${name}" { nativeBuildInputs = inputs; } ''
              cd ${src}
              ${cmd}
              touch $out
            '';
        in
        {
          format = run "format" [ pkgs.nixfmt ] "find . -name '*.nix' -exec nixfmt --check {} +";
          deadnix = run "deadnix" [ pkgs.deadnix ] "deadnix --fail --no-lambda-arg .";
          statix = run "statix" [ pkgs.statix ] "statix check .";
          gitleaks = run "gitleaks" [
            pkgs.gitleaks
          ] "gitleaks dir --no-banner --redact --exit-code 1 .";
          # Parse the real NixOS Hyprland config (cc1: hyprland.lua + sources.lua) with the locked Hyprland
          hyprland-config =
            let
              host = self.nixosConfigurations.cc1.config;
              hm = host.home-manager.users.${host.myModules.host.user};
            in
            pkgs.runCommand "check-hyprland-config" { nativeBuildInputs = [ pkgs.hyprland ]; } ''
              export HOME=$TMPDIR XDG_RUNTIME_DIR=$TMPDIR XDG_CONFIG_HOME=$TMPDIR/.config
              mkdir -p $XDG_CONFIG_HOME && cp -r ${./static/hypr} $XDG_CONFIG_HOME/hypr && chmod -R u+w $XDG_CONFIG_HOME
              cp ${./static/hypr-choose/sources-nixos.lua} $XDG_CONFIG_HOME/hypr/sources.lua
              cp ${
                pkgs.writeText "hyprland.lua" hm.xdg.configFile."hypr/hyprland.lua".text
              } $XDG_CONFIG_HOME/hypr/hyprland.lua
              Hyprland --verify-config -c $XDG_CONFIG_HOME/hypr/hyprland.lua 2>&1 | tee log
              grep -q '^config ok' log
              touch $out
            '';
        };

      # `nix build .#<name>` for everything in pkgs/
      packages.${system} = import ./pkgs { inherit pkgs; };

      # nixosConfigurations.<host> for every hosts/<host>/<host>-meta.nix, plus the installer ISO
      nixosConfigurations = lib.mapAttrs (_: hosts.mkNixos) hosts.hosts // {
        installer = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            inputs.disko.nixosModules.disko
            ./hosts/installer/installer.nix
          ];
        };
      };

      # `colmena apply --on @tag`; same module list as nixosConfigurations.
      # Hosts with `frozen = true` in their meta are left out, so no apply can touch them.
      colmenaHive = inputs.colmena.lib.makeHive (
        {
          meta = {
            nixpkgs = nixpkgs.legacyPackages.${system}; # config/overlays come from the modules
            specialArgs = { inherit inputs; };
          };
        }
        // lib.mapAttrs (_: host: {
          imports = hosts.nixosModules host ++ [ hosts.colmenaShim ];
          inherit (host) deployment;
        }) (lib.filterAttrs (_: host: !(host.frozen or false)) hosts.hosts)
      );
    };
}
