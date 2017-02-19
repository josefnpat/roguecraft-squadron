-- Thanks @bartbes! fixes cygwin buffer
io.stdout:setvbuf("no")

vn = {
  adj = {
    default = love.graphics.newImage("vn/adj/default.png"),
  }
}

fonts = {
  default = love.graphics.newFont("fonts/Yantramanav-Black.ttf",16),
  title = love.graphics.newFont("fonts/Yantramanav-Black.ttf",64),
  menu = love.graphics.newFont("fonts/Yantramanav-Black.ttf",32),
  vn_name = love.graphics.newFont("fonts/Yantramanav-Black.ttf",48),
  vn_text = love.graphics.newFont("fonts/Yantramanav-Black.ttf",24),
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
  splash = require "libs.splash",
  vn = require"libs.vn",
}

states = {
  splash = require "states.splash",
  menu = require "states.menu",
  game = require "states.mission",
  credits = require "states.credits",
}

function love.load()
  libs.hump.gamestate.registerEvents()
  libs.hump.gamestate.switch(states.splash)
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
