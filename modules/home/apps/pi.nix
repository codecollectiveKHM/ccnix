{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.pi.enable = lib.mkEnableOption "pi";
  config = lib.mkIf config.myModules.apps.pi.enable {
    home.packages = [ pkgs.pi-coding-agent ]; # pkgs/pi-coding-agent.nix (version pin)

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
