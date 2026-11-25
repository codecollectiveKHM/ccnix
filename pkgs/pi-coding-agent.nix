# npx wrapper, pinned: bump the version by hand (npm view @earendil-works/pi-coding-agent version).
# node on PATH for pi's `#!/usr/bin/env node`; fd/rg so pi doesn't download its own.
{
  lib,
  writeShellScriptBin,
  nodejs,
  fd,
  ripgrep,
}:
writeShellScriptBin "pi" ''
  export PATH=${
    lib.makeBinPath [
      nodejs
      fd
      ripgrep
    ]
  }:$PATH
  exec npx --yes @earendil-works/pi-coding-agent@1.6.0 "$@"
''
