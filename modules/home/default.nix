# Home Manager entry for every HM user (lib/default.nix: home-manager.sharedModules):
# auto-imported apps/ and bundles/, all option-gated; hosts only set options.
# home.username/homeDirectory come from the NixOS user (HM's NixOS module).
{ lib, inputs, ... }:
let
  nixFiles = dir: builtins.filter (lib.hasSuffix ".nix") (lib.filesystem.listFilesRecursive dir);
in
{
  imports = [
    inputs.ags.homeManagerModules.default # before anything references programs.ags
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./ai-endpoints.nix
  ]
  ++ nixFiles ./bundles
  ++ nixFiles ./apps;

  programs.home-manager.enable = true;
  # nix-flatpak follows the system's services.flatpak.enable; only apps/flatpak.nix turns it on
  services.flatpak.enable = lib.mkDefault false;

  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;
}
