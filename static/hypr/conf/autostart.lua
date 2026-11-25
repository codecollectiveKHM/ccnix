-- Ported from autostart.conf
-- dbus/systemd env import is handled by home-manager (systemd.variables = [ "--all" ]).
-- hyprctl.sh is gone: its overrides live in look.lua.

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("dunst")
    hl.exec_cmd("hypridle")
end)
