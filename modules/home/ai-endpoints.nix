# OpenAI-compatible model endpoints: data only. Clients (apps/pi.nix) render their own config.
# Sources: local ollama (this host's loadModels), local edge0 (features/edge0.nix), and the
# repo's edge0 servers (myModules.ai.edge0Servers, set in base/site.nix): each one other than
# this host gets an ssh tunnel `ssh -fN edge0-<name>` and a matching endpoint.
{
  config,
  lib,
  osConfig,
  ...
}:
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
  server = types.submodule {
    options = {
      sshHost = mkOption { type = types.str; };
      sshUser = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      sshPort = mkOption {
        type = types.port;
        default = 22;
      };
      localPort = mkOption {
        type = types.port;
        description = "Local end of the tunnel to the server's 127.0.0.1:8000.";
      };
    };
  };

  # pi metadata for ollama models; unknown ids get their id as name and a small context
  ollamaModels = {
    "gemma4" = {
      name = "Gemma 4 (Local)";
      contextWindow = 262144;
    };
    "gemma4:e2b" = {
      name = "Gemma 4 E2B (Local)";
      contextWindow = 131072;
    };
    "batiai/qwen3.6-35b:iq4" = {
      name = "Qwen 3.6 35B (IQ4)";
      contextWindow = 131072;
    };
    "llava:13b" = {
      name = "LLaVA 13B (Local)";
      contextWindow = 4096;
      tools = false;
      images = true;
    };
  };
  ollama = osConfig.services.ollama;
  remote = lib.filterAttrs (
    name: _: name != config.myModules.host.name
  ) config.myModules.ai.edge0Servers;
in
{
  options.myModules.ai = {
    endpoints = mkOption {
      type = types.attrsOf endpoint;
      default = { };
      description = "Model endpoints every AI client on this user gets.";
    };
    edge0Servers = mkOption {
      type = types.attrsOf server;
      default = { };
      description = "Hosts that can run edge0 (attr name = host name), reachable from this repo's machines.";
    };
  };

  config = {
    myModules.ai.endpoints =
      lib.optionalAttrs ollama.enable {
        ollama = {
          baseUrl = "http://localhost:11434/v1";
          apiKey = "ollama";
          models = lib.genAttrs ollama.loadModels (
            id:
            ollamaModels.${id} or {
              name = id;
              contextWindow = 8192;
            }
          );
        };
      }
      // lib.mapAttrs' (
        name: s:
        lib.nameValuePair "edge0-${name}" {
          baseUrl = "http://localhost:${toString s.localPort}/v1";
          models.edge0_145b = {
            name = "Edge0 145B (${name})";
            contextWindow = 131072;
          };
        }
      ) remote;

    programs.ssh.settings = lib.mapAttrs' (
      name: s:
      lib.nameValuePair "edge0-${name}" (
        {
          HostName = s.sshHost;
          Port = s.sshPort;
          LocalForward = "${toString s.localPort} localhost:8000";
          ExitOnForwardFailure = "yes"; # fail loudly if the local port is taken
          ControlMaster = "no"; # own process, so pkill closes it
        }
        // lib.optionalAttrs (s.sshUser != null) { User = s.sshUser; }
      )
    ) remote;
  };
}
