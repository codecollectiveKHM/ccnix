# Host discovery + builders.
# A host is hosts/<name>/<name>-meta.nix plus <name>-config.nix (NixOS) and <name>.nix (HM).
# Host-prefixed names keep files unique for fd/fzf/editor tabs.
# Host facts reach modules as `config.myModules.host.*`; `inputs` is the only specialArg.
{ inputs }:
let
  inherit (inputs.nixpkgs) lib;

  # One nixpkgs policy for NixOS and the devShell
  nixpkgsArgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlays.default
      (final: _: import ../pkgs { pkgs = final; }) # pkgs/ → pkgs.<name>
    ];
  };

  hosts = lib.mapAttrs (name: _: import ../hosts/${name}/${name}-meta.nix // { inherit name; }) (
    lib.filterAttrs (
      name: type: type == "directory" && builtins.pathExists ../hosts/${name}/${name}-meta.nix
    ) (builtins.readDir ../hosts)
  );

  facts = host: {
    myModules.host = { inherit (host) name user; };
  };

  # Shared by nixosSystem and colmena
  nixosModules = host: [
    ../modules/common/host.nix
    (facts host)
    ../hosts/${host.name}/${host.name}-config.nix
    ../modules/nixos
    {
      networking.hostName = host.name;
      nixpkgs = {
        hostPlatform = host.system;
        inherit (nixpkgsArgs) config overlays;
      };
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs; };
        # Every HM user (primary + lab users) gets the option-gated module tree
        sharedModules = [
          ../modules/common/host.nix
          (facts host)
          ../modules/home
        ];
        users.${host.user}.imports = [ ../hosts/${host.name}/${host.name}.nix ];
      };
    }
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
  ];

  # What lib.nixosSystem injects but colmena's own evaluator doesn't, so
  # `colmena apply` builds the same system as `nixos-rebuild switch`.
  colmenaShim = {
    system.nixos = {
      versionSuffix = ".${lib.substring 0 8 inputs.nixpkgs.lastModifiedDate}.${inputs.nixpkgs.shortRev}";
      revision = inputs.nixpkgs.rev;
    };
    nixpkgs.flake.source = inputs.nixpkgs.outPath;
  };

  mkNixos =
    host:
    lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = nixosModules host;
    };
in
{
  inherit
    nixpkgsArgs
    hosts
    nixosModules
    colmenaShim
    mkNixos
    ;
}
