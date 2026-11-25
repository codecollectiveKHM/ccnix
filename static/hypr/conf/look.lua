-- Ported from general/decoration/animations/layouts/misc.conf.
-- The old hyprctl.sh/hyprctl.json overrides are merged in as final values (marked "json").

hl.config({
    general = {
        gaps_in                 = 1, -- json (conf: 5)
        gaps_out                = 1, -- json (conf: 20)
        gaps_workspaces         = 0, -- json
        border_size             = 2,
        col = {
            active_border   = "rgb(f66151)", -- json (conf: 33ccffee→00ff99ee 45deg)
            inactive_border = "rgba(595959aa)",
        },
        layout                  = "dwindle",
        resize_on_border        = true,
        hover_icon_on_border    = true, -- json
        extend_border_grab_area = 15,   -- json
        allow_tearing           = false,
    },

    decoration = {
        rounding           = 10,
        active_opacity     = 1.0, -- json
        inactive_opacity   = 1.0, -- json
        fullscreen_opacity = 1.0, -- json
        dim_inactive       = true, -- json
        dim_strength       = 0.2,  -- json
        dim_special        = 0.2,  -- json
        dim_around         = 0.5,  -- json
        shadow = {
            enabled      = true,
            render_power = 3, -- json (was decoration:shadow_render_power)
        },
        blur = {
            enabled           = false, -- json (conf: true)
            size              = 6,     -- json (conf: 3)
            passes            = 1,
            contrast          = 1.3,   -- json
            brightness        = 0.6,   -- json
            vibrancy          = 0.4,   -- json
            vibrancy_darkness = 0.2,   -- json
            noise             = 0.0,   -- json
            ignore_opacity    = false, -- json
            popups            = false, -- json
        },
    },

    animations = { enabled = false }, -- json (conf: true)

    dwindle = { preserve_split = true }, -- pseudotile option removed; pseudo dispatcher always works

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },

    debug = { vfr = true }, -- was misc:vfr (battery)

    xwayland = { force_zero_scaling = true }, -- was in sources-*.conf
})

-- Inert while animations.enabled = false; kept for re-enabling.
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 4,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 1,  bezier = "default" })
