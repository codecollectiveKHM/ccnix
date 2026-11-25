# opencode agent CLI (npx) + its config, rendered from myModules.ai.endpoints
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.opencode.enable = lib.mkEnableOption "opencode";
  config = lib.mkIf config.myModules.apps.opencode.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "opencode" ''
        export PATH="${pkgs.nodejs}/bin:$PATH"
        if [ -n "''${DEEPSEEK_API_KEY:-}" ]; then
          export OPENCODE_DEEPSEEK_API_KEY="$DEEPSEEK_API_KEY"
        fi
        exec npx opencode-ai@1.19.6 "$@" # pinned: bump by hand (npm view opencode-ai version)
      '')
    ];

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      provider = lib.mapAttrs (n: e: {
        npm = "@ai-sdk/openai-compatible";
        name = n;
        options = {
          baseURL = e.baseUrl;
          inherit (e) apiKey;
        };
        models = lib.mapAttrs (_: m: { inherit (m) name; }) e.models;
      }) config.myModules.ai.endpoints;
    };
  };
}
