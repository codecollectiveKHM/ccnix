# Host facts, set by lib/default.nix from hosts/<name>/<name>-meta.nix.
# Imported by NixOS and Home Manager so modules never hardcode a user.
{ config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.myModules.host = {
    name = mkOption {
      type = types.str;
      description = "Host name (directory under hosts/).";
    };
    user = mkOption {
      type = types.str;
      description = "Primary user.";
    };
    flakePath = mkOption {
      type = types.str;
      default = "/home/${config.myModules.host.user}/.config/home-manager";
      description = "Local checkout of this flake (nh, out-of-store symlinks).";
    };
  };
}
