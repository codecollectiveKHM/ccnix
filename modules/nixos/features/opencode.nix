{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.system.opencode.enable = lib.mkEnableOption "opencode agent CLI";

  config = lib.mkIf config.myModules.system.opencode.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "opencode" ''
        export PATH="${pkgs.nodejs}/bin:$PATH"
        if [ -n "$DEEPSEEK_API_KEY" ]; then
          export OPENCODE_DEEPSEEK_API_KEY="$DEEPSEEK_API_KEY"
        fi
        exec npx opencode-ai@latest "$@"
      '')
    ];
  };
}
