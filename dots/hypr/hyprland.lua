-- ╔═══════════════════════════════════════════════╗
-- ║   COBRA QUEEN · hyprland.lua                  ║
-- ║   Hyprland 0.57+ (Lua config)                 ║
-- ╚═══════════════════════════════════════════════╝

-- ── Palette (mirrors colors.conf, which hyprlock still uses) ──
local c = {
    base    = "rgb(07090b)",
    border  = "rgba(1f3638aa)",
    venom   = "rgb(3bf0b6)",   -- mint glow — primary accent
    toxic   = "rgb(8a7bff)",   -- violet sheen — highlight
    hood    = "rgb(ff2d63)",   -- crimson — secondary accent
}

-- ── Monitors ─────────────────────────────────────
-- Alienware 15 panel: 1920x1200 @ 165Hz (check name with `hyprctl monitors`)
hl.monitor({ output = "eDP-1", mode = "1920x1200@165", position = "0x0", scale = 1 })
-- Anything else you plug in
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- ── Programs ─────────────────────────────────────
local terminal    = "kitty"
local fileManager = "thunar"
local browser     = "google-chrome-stable"
local menu        = "rofi -show drun"
local powermenu   = "~/.config/rofi/powermenu.sh"
local visualizer  = "kitty --class cava -o background_opacity=0.55 -o window_padding_width=12 cava"

-- ── Autostart ────────────────────────────────────
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- Cobra assistant (github.com/wattsnathan01-boop/cobra-ai); needs Hyprland's env for hyprctl
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP && systemctl --user start cobra")
    hl.exec_cmd("qs -n -c cobra")
end)

-- ── Environment ──────────────────────────────────
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- ── GPU: Intel iGPU + RTX 5060 (hybrid) ──────────
-- The Intel iGPU drives the laptop panel, so the desktop runs on it
-- (cool + quiet + good battery). Heavy apps go on the RTX 5060 with:
--     prime-run <app>          e.g. Steam launch options: prime-run %command%
-- If you mostly use an external monitor on the HDMI/USB-C port (often wired
-- to the NVIDIA GPU), uncomment these:
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("NVD_BACKEND", "direct")
-- hl.config({ cursor = { no_hardware_cursors = true } })

-- ── Look & feel ──────────────────────────────────
hl.config({
    general = {
        gaps_in     = 6,
        gaps_out    = 14,
        border_size = 2,

        col = {
            active_border   = { colors = { c.venom, c.toxic, c.hood }, angle = 45 },
            inactive_border = c.border,
        },

        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding         = 12,
        active_opacity   = 1.0,
        inactive_opacity = 0.94,

        shadow = {
            enabled        = true,
            range          = 24,
            render_power   = 3,
            color          = "rgba(3bf0b626)",
            color_inactive = "rgba(00000066)",
        },

        blur = {
            enabled           = true,
            size              = 8,
            passes            = 3,
            new_optimizations = true,
            vibrancy          = 0.18,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        background_color         = c.base,
    },

    -- ── Input ────────────────────────────────────
    input = {
        kb_layout    = "gb",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

-- Strike: fast in, slight overshoot — like a cobra lunge
hl.curve("strike", { type = "bezier", points = { {0.22, 1.2}, {0.36, 1} } })
hl.curve("coil",   { type = "bezier", points = { {0.65, 0},   {0.35, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0},      {1, 1}    } })

hl.animation({ leaf = "windows",     enabled = true, speed = 5,  bezier = "strike", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 4,  bezier = "coil",   style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 8,  bezier = "coil" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 60, bezier = "linear", style = "loop" })
hl.animation({ leaf = "fade",        enabled = true, speed = 4,  bezier = "coil" })
hl.animation({ leaf = "layers",      enabled = true, speed = 4,  bezier = "strike", style = "slide" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5,  bezier = "strike", style = "slidefade 15%" })

-- ── Keybinds ─────────────────────────────────────
local mod = "SUPER"

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + Q",      hl.dsp.window.close())
hl.bind(mod .. " + F",      hl.dsp.window.fullscreen())
hl.bind(mod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",      hl.dsp.window.pseudo())
hl.bind(mod .. " + J",      hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + L",      hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd(powermenu))
hl.bind(mod .. " + A",      hl.dsp.exec_cmd(visualizer))
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p clip | cliphist decode | wl-copy"))

-- Cobra: hold to talk
hl.bind(mod .. " + C", hl.dsp.exec_cmd("~/.local/bin/cobractl listen start"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd("~/.local/bin/cobractl listen stop"), { release = true })
-- Cobra: full HUD
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("~/.local/bin/cobractl hud"))

-- Screenshots
hl.bind("Print",         hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim - | wl-copy"))

-- Focus / move windows
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mod .. " + " .. dir,             hl.dsp.focus({ direction = dir }))
    hl.bind(mod .. " + SHIFT + " .. dir,     hl.dsp.window.move({ direction = dir }))
end

-- Workspaces 1–6 (shown as 壱 弐 参 肆 伍 陸 in waybar)
for i = 1, 6 do
    hl.bind(mod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse move / resize
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media & hardware keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 5%+"),                           { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"),                           { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- ── Rules ────────────────────────────────────────
hl.window_rule({ name = "float-pavucontrol", match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true })
hl.window_rule({ name = "float-nm-editor",   match = { class = "^(nm-connection-editor)$" },      float = true })
hl.window_rule({ name = "float-blueman",     match = { class = "^(blueman-manager)$" },           float = true })
hl.window_rule({ name = "cava",              match = { class = "^(cava)$" },                      float = true, size = "900 320", center = true })
hl.window_rule({ name = "pip",               match = { title = "^(Picture-in-Picture)$" },        float = true, pin = true })
hl.window_rule({ name = "cobra-settings",    match = { title = "^(Cobra settings)$" },            float = true, size = "1400 880", center = true })

hl.layer_rule({ name = "blur-waybar",        match = { namespace = "waybar" },        blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ name = "blur-rofi",          match = { namespace = "rofi" },          blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ name = "blur-notifications", match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ name = "blur-cobra",         match = { namespace = "cobra" },         blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ name = "blur-cobra-hud",     match = { namespace = "cobra-hud" },     blur = true })
