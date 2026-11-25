# Local packages, exposed as an overlay (lib/default.nix: pkgs.<name>) and as
# flake `packages.<system>.*`, so `nix build .#<name>` works and CI can build them.
# Prebuilt upstream binaries carry a `-bin` suffix (nixpkgs has different
# `pureref`/`t3code` packages).
{ pkgs }:
{
  pi-coding-agent = pkgs.callPackage ./pi-coding-agent.nix { };
  pureref-bin = pkgs.callPackage ./pureref-bin.nix { };
  t3code-bin = pkgs.callPackage ./t3code-bin.nix { };
}
