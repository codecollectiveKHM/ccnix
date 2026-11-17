{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.pi.enable = lib.mkEnableOption "pi";
  config = lib.mkIf config.myModules.apps.pi.enable {
    home.packages = [
      # Creates a localized transient binary wrapper using node/npx
      (pkgs.writeShellScriptBin "pi" ''
        # node for pi's `#!/usr/bin/env node`; fd/rg so pi doesn't download its own
        export PATH=${lib.makeBinPath [ pkgs.nodejs pkgs.fd pkgs.ripgrep ]}:$PATH
        exec npx --yes @earendil-works/pi-coding-agent "$@"
      '')
    ];

    home.file.".pi/agent/models.json".text = builtins.toJSON {
      providers = lib.mapAttrs (_: e: {
        inherit (e) baseUrl apiKey;
        api = "openai-completions";
        models = lib.mapAttrsToList (id: m: {
          inherit id;
          inherit (m) name contextWindow;
          supportsTools = m.tools;
          supportsImages = m.images;
        }) e.models;
      }) config.myModules.ai.endpoints;
    };

  };
}
