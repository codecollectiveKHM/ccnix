# OpenAI-compatible model endpoints: data only. Clients (apps/pi.nix)
# render their own config from it. Hosts add endpoints, e.g. hosts/cc2/cc2.nix (edge0).
{ lib, osConfig, ... }:
let
  inherit (lib) mkOption types;
  model = types.submodule {
    options = {
      name = mkOption { type = types.str; };
      contextWindow = mkOption { type = types.int; };
      tools = mkOption {
        type = types.bool;
        default = true;
      };
      images = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  endpoint = types.submodule {
    options = {
      baseUrl = mkOption { type = types.str; };
      apiKey = mkOption {
        type = types.str;
        default = "none";
      };
      models = mkOption { type = types.attrsOf model; }; # attr name = model id
    };
  };
in
{
  options.myModules.ai.endpoints = mkOption {
    type = types.attrsOf endpoint;
    default = { };
    description = "Model endpoints every AI client on this user gets.";
  };

  config.myModules.ai.endpoints.ollama = lib.mkDefault {
    baseUrl = "http://localhost:11434/v1";
    apiKey = "ollama";
    models = {
      "gemma4:e2b" = {
        name = "Gemma 4 (Local)";
        contextWindow = 262144;
      };
      "batiai/qwen3.6-35b:iq4" = {
        name = "Qwen 3.6 35B (IQ4)";
        contextWindow = 131072;
      };
    };
  };

  # cc2's Edge0 on hosts that don't run it, through `ssh -fN edge0-cc2` (apps/ssh.nix).
  # Local 18000, not 8000: cc1's JupyterHub holds 127.0.0.1:8000.
  config.myModules.ai.endpoints.edge0-cc2 = lib.mkIf (!osConfig.myModules.system.edge0.enable) {
    baseUrl = "http://localhost:18000/v1";
    models.edge0_145b = {
      name = "Edge0 145B (cc2)";
      contextWindow = 131072;
    };
  };
}
