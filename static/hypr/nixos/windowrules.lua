-- Ported from nixos/windowrules.conf
local function modal(name, match, size, extra)
	local r = { name = name, match = match, float = true, center = true, size = size }
	for k, v in pairs(extra or {}) do
		r[k] = v
	end
	hl.window_rule(r)
end

modal("yazi-picker-rules", { class = "^(yazi-picker)$" }, "1500 800", { stay_focused = true, dim_around = true })
modal(
	"gpg-pinentry-rules",
	{ class = "^(pinentry.*)$" },
	"400 200",
	{ stay_focused = true, dim_around = true, pin = true }
)
modal(
	"vault-auth-popup",
	{ class = "^(vault-pass)$" },
	"400 200",
	{ stay_focused = true, dim_around = true, focus_on_activate = true }
)
modal(
	"zotero-settings",
	{ class = "^(Zotero)$", title = "^(Zotero Settings)$" },
	"800 600",
	{ focus_on_activate = true }
)

-- Ignore client maximize requests (kitty maximizes itself after mapping)
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
