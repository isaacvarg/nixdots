local mainMod = "SUPER"
local terminal = "ghostty"

local function themeBackground()
  local cache = os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache")
  local hex = "1e2030"
  local f = io.open(cache .. "/skwd-wall-v2/quickshell-colors.json", "r")
  if f then
    hex = f:read("a"):match('"background"%s*:%s*"#(%x%x%x%x%x%x)"') or hex
    f:close()
  end
  return 0xFF000000 | tonumber(hex, 16)
end

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
  },

  input = {
    kb_layout = "us",
    follow_mouse = 1,
  },

  misc = {
    focus_on_activate = true,
    allow_session_lock_restore = true,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
    background_color = themeBackground(),
  },

  decoration = {
    rounding = 12,
  },

})

-- programs
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("screenshot"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("skwd-wall-v2"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("lock-screen"))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("qs ipc call powermenu toggle"))

-- window manipulation
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- window focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- workspace
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end


-- volume
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)

-- brightness
-- hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- media playing
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

