{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.system.audio.enable = lib.mkEnableOption "PipeWire audio";

  config = lib.mkIf config.myModules.system.audio.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true; # real time scheduling D-Bus system daemon
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    # JACK apps: launch via `pw-jack <app>` (jack.enable is deprecated)
    environment.systemPackages = [ pkgs.pipewire.jack ];
  };
}
