-- Ported from nixos/monitor.conf
-- hl.monitor({ output = "DP-1",     mode = "3840x2160@60", position = "auto", scale = 1.5 })
-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "auto", scale = 1.75 })
-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "auto", scale = 1, transform = 3 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "auto", scale = 1, mirror = "eDP-1" })

hl.monitor({ output = "eDP-1", mode = "highres", position = "auto", scale = 1.5 })

-- Universal fallback for unknown displays
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
