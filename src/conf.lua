game_name = "RogueCraft Squadron"
git_hash,git_count = "missing git.lua",-1
pcall( function() return require("git") end );

function love.conf(t)
  t.window.width = 1280
  t.window.height = 720
  t.window.title = game_name
end
