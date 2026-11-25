-- Ported from nixos/binds.conf
local mod = "SUPER"
local exec = hl.dsp.exec_cmd
local function b(keys, action, opts)
	hl.bind(mod .. " + " .. keys, action, opts)
end

-- Apps
b("O", exec("obsidian"))
b("T", exec("kitty -e vifm"))
b("U", exec("kitty -e nvim"))
b("Y", exec("kitty -e yazi"))
b("SHIFT + Y", exec("mpv-clipboard"))
b("D", exec("~/.scripts/toggle_kitty_opacity.sh"))
b("Z", exec("~/.scripts/toggle-touchpad.sh"))
b("C", exec("hyprshot -m region --clipboard-only"))
b("R", exec("~/.scripts/rotate-monitor.sh"))
b("B", exec("firefox"))
b("SHIFT + B", exec("~/.scripts/reload-waybar.sh"))
b("SHIFT + W", exec("~/.scripts/reload-hyprpaper.sh"))
b("E", exec("dolphin")) -- Plasma's file manager (workstation role)
b("CTRL + RETURN", exec("rofi -show drun"))
b("RETURN", exec('kitty -- zsh -c "zellij attach -c -f $(hostname); exec zsh"'))
b("CTRL + SHIFT + ALT + RETURN", exec("kitty"))
b("SHIFT + RETURN", exec('kitty zsh -ic "v"'))

-- Toggle laptop screen (was hyprctl monitors | grep && hyprctl keyword monitor ...)
b("SHIFT + R", function()
	local m = hl.get_monitor("eDP-1")
	if m and m.enabled then
		hl.monitor({ output = "eDP-1", disabled = true })
	else
		hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
	end
end)

-- Waybar toggle (bindit / bindirt)
b("SUPER_L", exec("pkill -SIGUSR1 waybar"), { ignore_mods = true, transparent = true })
b("SUPER_L", exec("pkill -SIGUSR1 waybar"), { ignore_mods = true, release = true, transparent = true })
b("W", exec("pkill -SIGUSR1 waybar"))

-- Session / window actions
b("Q", hl.dsp.window.close())
b("M", exec("hyprlock"))
b("SHIFT + M", exec("systemctl --user stop graphical-session.target && hyprctl dispatch 'hl.dsp.exit()'"))
b("SHIFT + S", exec("~/.scripts/switch-user.sh"), { locked = true }) -- also on hyprlock: SDDM for another user
b("G", hl.dsp.window.float({ action = "toggle" }))
b("F", hl.dsp.window.fullscreen())
b("P", hl.dsp.window.pseudo())
b("N", hl.dsp.layout("togglesplit"))

-- Media / brightness
hl.bind("XF86MonBrightnessDown", exec("brightnessctl set 10%-"), { repeating = true })
hl.bind("XF86MonBrightnessUp", exec("brightnessctl set 10%+"), { repeating = true })
b("9", exec("brightnessctl set 10%-"), { repeating = true })
b("0", exec("brightnessctl set 10%+"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%-"))
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_SINK@ toggle"))

-- Focus / move / resize
for key, dir in pairs({ H = "left", L = "right", K = "up", J = "down" }) do
	b(key, hl.dsp.focus({ direction = dir }))
	b("SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end
for key, d in pairs({ right = { 80, 0 }, left = { -80, 0 }, down = { 0, 50 }, up = { 0, -50 } }) do
	b("SHIFT + " .. key, hl.dsp.window.move({ x = d[1], y = d[2], relative = true }))
	b(key, hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }))
end

-- Workspaces: SUPER+1..8 switch (9/0 = brightness), SHIFT+1..0 move
for i = 1, 10 do
	local key = i % 10
	if i <= 8 then
		b(tostring(key), hl.dsp.focus({ workspace = i }))
	end
	b("SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
b("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
b("mouse_up", hl.dsp.focus({ workspace = "e-1" }))
