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
  adj = {
    correct = love.audio.newSource("assets/vn/adj/audio/correct.ogg"),
    incorrect = love.audio.newSource("assets/vn/adj/audio/incorrect.ogg"),
    warning = love.audio.newSource("assets/vn/adj/audio/warning.ogg"),
    line1 = love.audio.newSource("assets/vn/adj/audio/line1.ogg"),
    line2 = love.audio.newSource("assets/vn/adj/audio/line2.ogg"),
    line3 = love.audio.newSource("assets/vn/adj/audio/line3.ogg"),
    line4 = love.audio.newSource("assets/vn/adj/audio/line4.ogg"),
    line5 = love.audio.newSource("assets/vn/adj/audio/line5.ogg"),
    line6 = love.audio.newSource("assets/vn/adj/audio/line6.ogg"),
    line7 = love.audio.newSource("assets/vn/adj/audio/line7.ogg"),
    line8 = love.audio.newSource("assets/vn/adj/audio/line8.ogg"),
    line9 = love.audio.newSource("assets/vn/adj/audio/line9.ogg"),
  },
  com = {
    line1 = love.audio.newSource("assets/vn/com/audio/line1.ogg"),
    line2 = love.audio.newSource("assets/vn/com/audio/line2.ogg"),
    line3 = love.audio.newSource("assets/vn/com/audio/line3.ogg"),
    line4 = love.audio.newSource("assets/vn/com/audio/line4.ogg"),
    line5 = love.audio.newSource("assets/vn/com/audio/line5.ogg"),
    line6 = love.audio.newSource("assets/vn/com/audio/line6.ogg"),
    line7 = love.audio.newSource("assets/vn/com/audio/line7.ogg"),
    line8 = love.audio.newSource("assets/vn/com/audio/line8.ogg"),
    line9 = love.audio.newSource("assets/vn/com/audio/line9.ogg"),
    line10 = love.audio.newSource("assets/vn/com/audio/line10.ogg"),
    line11 = love.audio.newSource("assets/vn/com/audio/line11.ogg"),
    line12 = love.audio.newSource("assets/vn/com/audio/line12.ogg"),
    line13 = love.audio.newSource("assets/vn/com/audio/line13.ogg"),
    line14 = love.audio.newSource("assets/vn/com/audio/line14.ogg"),
    line15 = love.audio.newSource("assets/vn/com/audio/line15.ogg"),
  },
}

difficulty = {
  mult = {
    asteroid = 1,
    enemy = 1,
    scrap = 1,
    station = 1,
  },
  tutorial_asteroid = 6,
  tutorial_scrap = 4,
  tutorial_station = 4,
  tutorial_enemy = 2,
  low_asteroid = 10,
  low_enemy = 10,
  medium_asteroid = 25,
  medium_enemy = 25,
  high_asteroid = 50,
  high_enemy = 50,
  insane_asteroid = 100,
  insane_enemy = 100,
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
  stars = require"libs.stars",
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

function love.load(arg)
  for i,v in pairs(arg) do
    if v == "novn" then
      disable_vn = true
    end
    if states[v] then
      target_state = states[v]
    end
    if v == "operationcwal" then
      cheat_operation_cwal = true
    end
    if v == "cheat" then
      cheat = true
    end
    if v == "debug" then
      debug_mode = true
    end
  end
  libs.hump.gamestate.registerEvents()
  libs.hump.gamestate.switch(target_state or states.splash)
end

function love.resize()
  libs.stars:reload()
end

function love.update(dt)
  love.mouse.setGrabbed(
    libs.hump.gamestate.current() == states.game and
    not states.game.vn:getRun() and
    love.window.hasFocus()
  )
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
  settings.bgm = source
  source:setVolume(settings.music_volume/10)
  if not settings.muted_music then
    love.audio.play(source)
  end
end

function playSFX(source)
  --hax hax hax
  if type(source) == "table" then
    for i = 1, #source do
      source[i]:stop()
    end
    if not settings.muted then
    local current_source = source[math.random(#source)]
    current_source:setVolume(settings.sound_volume/10)
      love.audio.play(current_source)
    end
  else
    source:stop()
    if not settings.muted then
    source:setVolume(settings.sound_volume/10)
      love.audio.play(source)
    end
  end
end

function loopSFX(source)
  if not source:isPlaying( ) and not settings.muted then
    love.audio.play(source)
  end
end

function getFileName(i)
  local _,_,fname,extension = i:find("^(.+)%.(.*)")
  return fname
end
