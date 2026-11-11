local mod = "SUPER"
local terminal = "ghostty"

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
})

hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + M", hl.dsp.exit())

for i = 1, 3 do
  hl.bind(mod .. " + " ..i, hl.dsp.focus({ workspace = i }))
end
