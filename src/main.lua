-- Thanks @bartbes! fixes cygwin buffer
io.stdout:setvbuf("no")

math.randomseed(os.time())

vn = {
  adj = {
    default = love.graphics.newImage("assets/vn/adj/default.png"),
	  overlay = {
      love.graphics.newImage("assets/vn/adj/shine1.png"),
      love.graphics.newImage("assets/vn/adj/shine2.png")
    },
  },
  com = {
    default = love.graphics.newImage("assets/vn/com/default.png"),
  }
}

vn_audio = {
  -- level 1
  {
    --love.audio.newSource("vn/1_1.wav","stream"),
    --love.audio.newSource("vn/1_2.wav","stream"),
  },
  -- level 2
  {
    --love.audio.newSource("vn/1_1.wav","stream"),
    --love.audio.newSource("vn/1_2.wav","stream"),
  },
}

difficulty = {
  tutorial_asteroid = 4,
  tutorial_enemy = 2,
  low_asteroid = 10,
  low_enemy = 10,
  medium_asteroid = 25,
  medium_enemy = 25,
  high_asteroid = 100,
  high_enemy = 100,
}

fonts = {
  default = love.graphics.newFont("fonts/Yantramanav-Black.ttf",16),
  title = love.graphics.newFont("fonts/ExpletusSans-Bold.ttf",64),
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
  pause = require "states.pause",
  options = require "states.options",
  lose = require "states.lose",
  win = require "states.win",
  game = require "states.mission",
  credits = require "states.credits",
}

bg = {
	space = love.graphics.newImage("assets/space.png"),
	stars0 = love.graphics.newImage("assets/stars0.png"),
	stars1 = love.graphics.newImage("assets/stars1.png"),
}

function love.load(arg)
  for i,v in pairs(arg) do
    if v == "novn" then
      disable_vn = true
    end
  end
  libs.hump.gamestate.registerEvents()
  libs.hump.gamestate.switch(states[arg[2]] or states.splash)
end

function love.update(dt)
  love.mouse.setGrabbed(
    libs.hump.gamestate.current() == states.game and
    not states.game.vn:getRun() and
    love.window.hasFocus()
  )
end

function love.keypressed(key)
  if key == "`" then
    --debug_mode = not debug_mode
  end
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

function playBGM(source)
	love.audio.stop()
	if not settings.muted then
		love.audio.play(source)
	end
end

function playSFX(source)
	source:stop()
	if not settings.muted then
		love.audio.play(source)
	end
end

function loopSFX(source)
	if not source:isPlaying( ) and not settings.muted then
		love.audio.play(source)
	end
end
