{
  config,
  lib,
  pkgs,
  ...
}:
let
  whisper = pkgs.whisper-cpp.override { cudaSupport = true; };
  models = builtins.readFile ../../static/whisper/models.sh;
  mkScript =
    name: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        whisper
        pkgs.curl
      ]
      ++ runtimeInputs;
      text = models + builtins.readFile (../../static/whisper + "/${name}.sh");
    };
in
{
  options.myModules.apps.whisper.enable =
    lib.mkEnableOption "whisper.cpp (CUDA) + transcribe/dictate";

  config = lib.mkIf config.myModules.apps.whisper.enable {
    home.packages = [
      whisper
      pkgs.ffmpeg
      (mkScript "transcribe" (
        with pkgs;
        [
          ffmpeg
          yt-dlp
          jq
          yq
          htmlq
        ]
      ))
      (mkScript "dictate" (
        with pkgs;
        [
          pipewire
          wl-clipboard
          wtype
          libnotify
        ]
      ))
    ];
    wayland.windowManager.hyprland.extraConfig = ''
      hl.bind("SUPER + ALT + D", hl.dsp.exec_cmd("dictate"))
    '';
  };
}
