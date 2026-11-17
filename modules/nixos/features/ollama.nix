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
      # Pulled by ollama-model-loader.service in the background, not at boot
      loadModels = [
        "llava:13b"
        "gemma4:e2b"
      ];
    };
  };
}
