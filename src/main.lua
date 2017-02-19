-- Thanks @bartbes!
io.stdout:setvbuf("no")

fonts = {
  default = love.graphics.newFont("fonts/Yantramanav-Black.ttf",16),
  fallback = love.graphics.newFont("fonts/NovaMono.ttf",16),
}

love.graphics.setFont(fonts.default)
fonts.default:setFallbacks(fonts.fallback)

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

function dropshadow(text,x,y)
  local color = {love.graphics.getColor()}
  love.graphics.setColor(0,0,0,191)
  love.graphics.print(text,x+2,y+2)
  love.graphics.setColor(color)
  love.graphics.print(text,x,y)
end

function dropshadowf(text,x,y,w,a)
  local color = {love.graphics.getColor()}
  love.graphics.setColor(0,0,0,191)
  love.graphics.printf(text,x+2,y+2,w,a)
  love.graphics.setColor(color)
  love.graphics.printf(text,x,y,w,a)
end
