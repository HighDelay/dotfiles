-- Color Palette (for reference)
-- ┌──────────────────┬───────────┐
-- │ Background Base  │ #0D0F14 │
-- │ Background Alt   │ #1A1D26 │
-- │ Surface          │ #262A35 │
-- │ Border Active    │ #C83C5E │
-- │ Border Inactive  │ #3A3D4A │
-- │ Accent Primary   │ #E84565 │
-- │ Accent Secondary │ #F5A0B3 │
-- │ Accent Tertiary  │ #2E6B7B │
-- │ Foreground       │ #F0E4E8 │
-- │ Foreground Dim   │ #8A8494 │
-- │ Urgent           │ #E84565 │
-- │ Active/Success   │ #6BAE8E │
-- └──────────────────┴───────────┘


--------------------
---- MONITORS ------
--------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
-- Uncomment for specific resolution:
-- hl.monitor({ output = "", mode = "1920x1080@75", position = "auto", scale = "auto" })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty --single-instance"
local fileManager = "thunar"
local menu        = "rofi -show drun -theme $HOME/.config/rofi/config.rasi"
local windowMenu  = "rofi -show window -theme $HOME/.config/rofi/config.rasi"
local clipboard   = "$HOME/.config/rofi/clipboard.sh"
local powermenu   = "$HOME/.config/rofi/powermenu/powermenu.sh"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar & swaync &")
    hl.exec_cmd("systemctl --user start hyprpolkitagent &")
    hl.exec_cmd("awww-daemon --quiet & awww img $HOME/dotfiles/wallpaper.png &")
    hl.exec_cmd("easyeffects &")
    hl.exec_cmd("wl-paste --type text --watch cliphist store &")
    hl.exec_cmd("wl-paste --type image --watch cliphist store &")
    hl.exec_cmd("fcitx5 &")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- NVIDIA ENV (comment out if you don't use Nvidia)
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- See https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    -- Input
    input = {
        kb_layout     = "us",
        follow_mouse  = 1,
        accel_profile = "flat",
        sensitivity   = 0,
        touchpad = {
            natural_scroll = false,
        },
    },

    -- Cursor
    cursor = {
        no_hardware_cursors = true,
    },

    -- General
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 3,

        col = {
            active_border   = { colors = {"rgba(C83C5Eee)", "rgba(E84565ee)"}, angle = 45 },
            inactive_border = "rgba(3A3D4Aaa)",
        },

        layout        = "dwindle",
        allow_tearing = true, -- Fix input latency
    },

    -- Decoration
    decoration = {
        rounding         = 4,
        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        blur = {
            enabled  = true,
            size     = 5,
            passes   = 2,
        },

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee0d0f14,
        },
    },

    -- Animations
    animations = {
        enabled = true,
    },

    -- Layouts
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },
})


----------------------------
---- CURVES & ANIMATIONS ---
----------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "borderangle",enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })


--------------------------
---- LAYER RULES ---------
--------------------------

hl.layer_rule({
    name  = "rofi-blur",
    match = { namespace = "rofi" },
    blur  = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name  = "waybar-blur",
    match = { namespace = "waybar" },
    blur  = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name  = "swaync-blur",
    match = { namespace = "swaync-control-center" },
    blur  = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name  = "swaync-notification-blur",
    match = { namespace = "swaync-notification-window" },
    blur  = true,
    ignore_alpha = 0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Apps
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + space",  hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Tab",    hl.dsp.exec_cmd(windowMenu))
hl.bind(mainMod .. " + V",      hl.dsp.exec_cmd(clipboard))

-- System
hl.bind(mainMod .. " + W",           hl.dsp.window.close())
hl.bind(mainMod .. " + ALT + Q",     hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + S",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen())
hl.bind("ALT + F4",                  hl.dsp.exec_cmd(powermenu))

-- Layout (dwindle)
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + O", hl.dsp.layout("togglesplit"))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd(
    'grim - | tee "$HOME/Pictures/$(date +\'%s_grim.png\')" | wl-copy && notify-send "Screenshot" "Fullscreen captured"'
))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(
    'grim -g "$(slurp)" - | tee "$HOME/Pictures/$(date +\'%s_grim.png\')" | wl-copy && notify-send "Screenshot" "Region captured"'
))

-- Focus (arrow keys)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Focus (vim keys)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Move Window
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Window Switching (ALT+Tab)
hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- Switch Workspaces (1-10) + Move Window to Workspace
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Mouse: scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e+1" }))

-- Mouse: move/resize windows
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
