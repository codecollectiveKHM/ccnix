-- Ported from environments.conf + cursor.conf (env order: last XCURSOR_SIZE wins = 24)

-- XDG Desktop Portal
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- QT
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

hl.env("GDK_SCALE", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("XCURSOR_SIZE", "24")
hl.env("APPIMAGELAUNCHER_DISABLE", "1")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("SVN_CONFIG_DIR", os.getenv("HOME") .. "/.config/subversion")

-- Reroute Chromium/Electron PKI certificates - breaks dolphin as file picker
-- hl.env("NSS_USER_DB_DIR", os.getenv("HOME") .. "/.local/share/pki/nssdb")

-- KVM virtual machines
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")
-- hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
