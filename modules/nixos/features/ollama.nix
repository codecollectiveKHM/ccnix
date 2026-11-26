{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.system.ollama.enable = lib.mkEnableOption "ollama (CUDA) with preloaded models";

  config = lib.mkIf config.myModules.system.ollama.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      # Models: services.ollama.loadModels in the host (or site) config; pulled in the background
    };
  };
}
