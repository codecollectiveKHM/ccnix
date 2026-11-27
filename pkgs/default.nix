# This repo's packages (shared ones live in nix-core's pkgs/): overlay pkgs.<name> and
# flake `packages.<system>.*` via mkFlake, so `nix build .#<name>` works and CI can build them.
# Prebuilt upstream binaries carry a `-bin` suffix (nixpkgs has a different `t3code`).
{ pkgs, ... }: # inputs: unused here, passed for parity with hm
{
  t3code-bin = pkgs.callPackage ./t3code-bin.nix { };
}
