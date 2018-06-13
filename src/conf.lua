settings = require"libs.settings".new()
settings:load()
settings:define("window_width",1280)
settings:define("window_height",720)
settings:define("window_fullscreen",false)
settings:define("window_fullscreen_type","desktop")
settings:define("window_display",1)
settings:define("window_msaa",2)
settings:define("camera_speed",1)
settings:define("bg_quality","medium")
settings:define("voiceover_vol",1)
settings:define("sfx_vol",1)
settings:define("music_vol",1)
settings:define("tutorial",true)
settings:define("fow_quality","img_canvas")
settings:define("tree_points",0)
settings:define("tree_levels",{})
settings:define("diff","new")
settings:define("remote_server_address","50.116.63.25")
settings:define("mouse_draw_mode","hardware")

game_name = "RogueCraft Squadron"
git_hash,git_count = "missing git.lua",-1
pcall( function() return require("git") end );

function love.conf(t)

  for _,v in pairs(arg) do
    if v == "--server" or v == "-s" then
      headless = true
    end
  end

  if headless then
    t.window = false
    t.modules.graphics = false
    t.modules.window = false
    t.modules.audio = false
  else
    t.window.width = settings:read("window_width")
    t.window.height = settings:read("window_height")
    t.window.title = game_name
    t.window.resizable = true
    t.window.fullscreen = settings:read("window_fullscreen")
    t.window.fullscreentype = "desktop"
    t.window.msaa = settings:read("window_msaa")
  end

end
