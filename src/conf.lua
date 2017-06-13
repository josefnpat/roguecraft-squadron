settings = require"libs.settings".new()
settings:load()
settings:define("window_width",1280)
settings:define("window_height",720)
settings:define("window_fullscreen",false)
settings:define("window_msaa",2)
settings:define("camera_speed",1)
settings:define("bg_quality","medium")
settings:define("voiceover_vol",1)
settings:define("sfx_vol",1)
settings:define("music_vol",1)
settings:define("tutorial",true)
settings:define("fow_quality","img_canvas")
settings:define("tree_points",0)

game_name = "RogueCraft Squadron"
git_hash,git_count = "missing git.lua",-1
pcall( function() return require("git") end );

function love.conf(t)
  t.window.width = settings:read("window_width")
  t.window.height = settings:read("window_height")
  t.window.title = game_name
  t.window.resizable = true
  t.window.fullscreen = settings:read("window_fullscreen")
  t.window.fullscreentype = "desktop"
  t.window.msaa = settings:read("window_msaa")
end
