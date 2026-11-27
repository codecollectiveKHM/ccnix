{
  description = "Code Collective lab: NixOS + Home Manager flake (shared modules: nix-core)";

  inputs = {
    # Shared modules, static files and lib.mkFlake. Lags on purpose: pin a reviewed tag,
    # e.g. github:Paramuno/nix-core/v2026.12.0; bump with `nix flake update core`, review, colmena.
    core.url = "github:Paramuno/nix-core";
    # One nixpkgs for both repos: core's lock decides
    nixpkgs.follows = "core/nixpkgs";

    # Particular sources
    # Claude's version comes from this repo's versions/*.json, not from nixpkgs
    nix-claude-code = {
      url = "github:ryoppippi/nix-claude-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pinned rev (b4d4ed4 failed to build on cc1): `nix flake update` can't move it. Bump: edit the
    # rev, `nix flake lock`, build cc1. No follows: its nixpkgs is what comfyui.cachix.org prebuilt.
    comfyui-nix.url = "github:utensils/comfyui-nix/308a863c136ffc35fce293a81eac5d229b31d56d";
  };

  outputs =
    inputs:
    inputs.core.lib.mkFlake {
      inherit inputs;
      root = ./.;
      tailnet = "tail92efad.ts.net"; # lab tailnet: change it here only
      keys = import ./lib/keys.nix;
      packages = import ./pkgs;
      hyprlandCheckHost = "cc1";
      # The installer ISO: not a hosts/ entry (no meta, no HM)
      extraOutputs =
        { lib, inputs, ... }:
        {
          nixosConfigurations.installer = lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              inputs.disko.nixosModules.disko
              ./hosts/installer/installer.nix
            ];
          };
        };
    };
}
