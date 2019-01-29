settings = require"libs.settings".new()
settings:load()
settings:define("window_width",1280)
settings:define("window_height",720)
settings:define("window_fullscreen",false)
settings:define("window_fullscreen_type","desktop")
settings:define("window_display",1)
settings:define("window_vsync",false)
settings:define("window_msaa",2)
settings:define("camera_speed",1)
settings:define("bg_quality","high")
settings:define("voiceover_vol",0.3)
settings:define("sfx_vol",0.2)
settings:define("music_vol",0.3)
settings:define("fow_quality","img_canvas")
settings:define("remote_server_address","127.0.0.1")
settings:define("user_name","Player")
settings:define("mouse_draw_mode","software")
settings:define("object_shaders",true)
settings:define("action_keys",{"z","x","c","v","b"})

game_tagline = "Call to Arms"
game_name = "RogueCraft Squadron: "..game_tagline
git_hash,git_count = "missing git.lua",-1
pcall( function() return require("git") end );

function love.conf(t)

  for _,v in pairs(arg) do
    if v == "--server" or v == "-s" then
      headless = true
    end
  end
  t.identity = "RogueCraftSquadron"

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
    t.window.fullscreentype = settings:read("window_fullscreen_type")
    t.window.window_display = settings:read("window_display")
    t.window.vsync = settings:read("window_vsync")
    t.window.msaa = settings:read("window_msaa")
    t.window.minwidth = 1280
    t.window.minheight = 720
  end

end
