# Every module below is auto-imported and does nothing until enabled,
# except base/ (applies to every NixOS host). Hosts only set options.
{ lib, ... }:
{
  imports = builtins.filter (f: f != ./default.nix && lib.hasSuffix ".nix" f) (
    lib.filesystem.listFilesRecursive ./.
  );
}
