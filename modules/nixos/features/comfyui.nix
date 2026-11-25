# ComfyUI (CUDA) from comfyui-nix. Its module replaces nixpkgs' services.comfyui
# on every host (imports can't be conditional); it stays off until enabled here.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myModules.system.comfyui;
in
{
  disabledModules = [ "services/misc/comfyui.nix" ];
  imports = [ inputs.comfyui-nix.nixosModules.default ];

  options.myModules.system.comfyui = {
    enable = lib.mkEnableOption "ComfyUI (CUDA) on 127.0.0.1:8188";
    tailscaleServe = lib.mkEnableOption "publishing ComfyUI on the tailnet (tailscale serve, HTTPS 443)";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        nixpkgs.overlays = [ inputs.comfyui-nix.overlays.default ];
        # comfyui-nix's caches live in its flake nixConfig, which its NixOS module doesn't carry
        nix.settings = {
          substituters = [
            "https://comfyui.cachix.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "comfyui.cachix.org-1:33mf9VzoIjzVbp0zwj+fT51HG0y31ZTK3nzYZAX0rec="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };

        services.comfyui = {
          enable = true;
          gpuSupport = "cuda";
          enableManager = true;
          dataDir = "/var/lib/comfyui";
          listenAddress = "127.0.0.1"; # reach it via SSH tunnel or tailscaleServe
          openFirewall = false;
          extraArgs = [ "--use-sage-attention" ];

          customNodes = {
            ComfyUI-Custom-Scripts = pkgs.fetchFromGitHub {
              owner = "pythongosssss";
              repo = "ComfyUI-Custom-Scripts";
              rev = "609f3afaa74b2f88ef9ce8d939626065e3247469";
              hash = "sha256-2GgTS7l/sMSnJb07sBifL8NGnDBF3g9qdlSKr3gYFGQ=";
            };
            ComfyUI-Z-Image-Turbo-Resolutions = pkgs.fetchFromGitHub {
              owner = "SaTaNoob";
              repo = "ComfyUI-Z-Image-Turbo-Resolutions";
              rev = "16d043905613ed085daaf4f6f339978a6a2ab86d";
              hash = "sha256-3I4yKOf5GOefSUjZHDnvV91PO553mGZLPcffxs9UsrI=";
            };
          };
        };
      }
      (lib.mkIf cfg.tailscaleServe {
        systemd.services.comfyui-serve = {
          after = [
            "tailscaled.service"
            "comfyui.service"
          ];
          requires = [ "comfyui.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            TimeoutStartSec = 30;
            ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --https=443 http://127.0.0.1:8188";
            ExecStop = "${pkgs.tailscale}/bin/tailscale serve --https=443 off";
          };
        };
      })
    ]
  );
}
