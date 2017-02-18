-- Thanks @bartbes!
io.stdout:setvbuf("no")

libs = {
  hump = {
    gamestate = require "libs.gamestate",
    camera = require "libs.camera",
  },
  healthcolor = require"libs.healthcolor",
}

states = {
  mission = require "states.mission",
}

function love.load()
  libs.hump.gamestate.registerEvents()
  libs.hump.gamestate.switch(states.mission)
end
