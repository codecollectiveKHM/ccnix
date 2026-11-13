-- NixOS entrypoint, required from the home-manager generated hyprland.lua
require("conf.environments")
require("conf.autostart")
require("conf.look")
require("conf.input")
require("conf.shared_binds")
require("nixos.binds")
require("nixos.windowrules")
require("nixos.monitor")
