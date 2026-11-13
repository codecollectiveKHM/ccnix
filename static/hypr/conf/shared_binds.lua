-- Ported from shared_binds.conf
local exec = hl.dsp.exec_cmd

hl.bind("SUPER + CTRL + O", exec('kitty zsh -ic "fetch-obsidianconfig"'))
hl.bind("SUPER + I", exec("~/.scripts/gemini-rofi.sh"))
hl.bind("SUPER + A", exec("ags -t visual-keyboard"))

-- AGS modifier tracking (bindin / bindrti)
local PRESS   = { ignore_mods = true, non_consuming = true }
local RELEASE = { ignore_mods = true, transparent = true, release = true }

local modBinds = {}
for key, name in pairs({ Shift_L = "shift", Control_L = "ctrl", Alt_L = "alt", Super_L = "super" }) do
    local file = "/tmp/ags-mod-" .. name
    table.insert(modBinds, hl.bind(key, exec("echo 1 > " .. file), PRESS))
    table.insert(modBinds, hl.bind(key, exec("echo 0 > " .. file), RELEASE))
end

-- Replaces bottles-mod-fix.sh: disable mod tracking while Proton/TouchDesigner is focused
local modsActive = true
hl.on("window.active", function(w)
    local id = w and ((w.class or "") .. " " .. (w.title or "")):lower() or ""
    local want = not (id:find("steam_proton", 1, true) or id:find("touchdesigner", 1, true))
    if want == modsActive then return end
    modsActive = want
    for _, b in ipairs(modBinds) do b:set_enabled(want) end
    if not want then
        hl.exec_cmd("for m in shift ctrl alt super; do echo 0 > /tmp/ags-mod-$m; done")
    end
end)

-- AGS chord tracking, F13–F17 intercepted from Kanata (bindin / bindrtir)
for key, chord in pairs({ XF86Tools = "space", XF86Launch5 = "z", XF86Launch6 = "s", XF86Launch7 = "g", XF86Launch8 = "v" }) do
    hl.bind(key, exec("echo " .. chord .. " > /tmp/ags-active-chord"), PRESS)
    hl.bind(key, exec("echo none > /tmp/ags-active-chord"), RELEASE)
end

-- Firefox: CTRL+Q → CTRL+W (native, replaces hyprctl activewindow | grep)
hl.bind("CTRL + Q", function()
    local w = hl.get_active_window()
    local key = (w and (w.class or ""):lower() == "firefox") and "w" or "q"
    hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = key }))
end)
