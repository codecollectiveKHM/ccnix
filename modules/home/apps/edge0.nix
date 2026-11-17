# Clients for the Edge0 server (NixOS myModules.system.edge0): opencode provider; pi.nix adds its own.
{ config, lib, ... }:
{
  options.myModules.apps.edge0.enable = lib.mkEnableOption "Edge0 provider in opencode and pi";
  config = lib.mkIf config.myModules.apps.edge0.enable {
    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      provider.edge0 = {
        npm = "@ai-sdk/openai-compatible";
        name = "Edge0 (local)";
        options = {
          baseURL = "http://localhost:8000/v1";
          apiKey = "none";
        };
        models.edge0_145b.name = "Edge0 145B";
      };
    };
  };
}
