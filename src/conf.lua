settings = require"libs.settings".new()
settings:load()

game_name = "RogueCraft Squadron"
git_hash,git_count = "missing git.lua",-1
pcall( function() return require("git") end );

function love.conf(t)
  t.window.width = settings:read("window_width",1280)
  t.window.height = settings:read("window_height",720)
  t.window.title = game_name
  t.window.resizable = true
  t.window.fullscreen = settings:read("window_fullscreen",false)
  t.window.fullscreentype = "desktop"
  t.window.msaa = settings:read("window_msaa",2)
end
