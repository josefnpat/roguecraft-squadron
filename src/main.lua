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
    --line9 = love.audio.newSource("assets/vn/adj/audio/line9.ogg"),
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
  },
}

function makeFonts()
  fonts = {
    default = love.graphics.newFont("assets/fonts/Yantramanav-Black.ttf",16),
    window_title = love.graphics.newFont("assets/fonts/ExpletusSans-Bold.ttf",20),
    title = love.graphics.newFont("assets/fonts/ExpletusSans-Bold.ttf",64),
    menu = love.graphics.newFont("assets/fonts/Yantramanav-Black.ttf",22),
    vn_name = love.graphics.newFont("assets/fonts/Yantramanav-Black.ttf",48),
    vn_text = love.graphics.newFont("assets/fonts/Yantramanav-Black.ttf",24),
    vn_info = love.graphics.newFont("assets/fonts/Yantramanav-Black.ttf",16),
    fallback = love.graphics.newFont("assets/fonts/NovaMono.ttf",16),
  }
end
makeFonts()

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
  score = require"libs.score",
  menu = require"libs.menu",
  pcb = require"libs.progresscirclebar",
  window = require"libs.window",
  tutorial = require"libs.tutorial",
  json = require"libs.json",
  notif = require"libs.notif",
  tree = require"libs.tree",
  assetchooser = require"libs.assetchooser",
  stringchooser = require"libs.stringchooser",
}

states = {
  splash = require "states.splash",
  menu = require "states.menu",
  pause = require "states.pause",
  options = require "states.options",
  lose = require "states.lose",
  win = require "states.win",
  tree = require"states.tree",
  mission = require "states.mission",
  credits = require "states.credits",
  disclaimer = require "states.disclaimer",
  debug = require "states.debug",
}

function love.load(arg)

  local cursor = love.graphics.newImage("assets/hud/cursor.png")
  love.mouse.setCursor(
    love.mouse.newCursor("assets/hud/cursor.png",
    cursor:getWidth()/2,cursor:getHeight()/2))
  cursor = nil

  local version_server_check = true

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
    if v == "nocheck" then
      version_server_check = false
    end
  end

  if version_server_check then
    local http = require"socket.http"
    local version_server_payload = libs.json.encode({count=git_count,hash=git_hash})
    local version_server_url = "http://50.116.63.25/roguecraftsquadron.com/version.php?i="
    local r,e = http.request(version_server_url..version_server_payload)
    version_server = e == 200 and libs.json.decode(r) or nil
  end

  libs.hump.gamestate.registerEvents()
  libs.hump.gamestate.switch(target_state or states.splash)
end

function love.resize()
  libs.stars:reload()
  states.mission:resize()
end

function love.update(dt)
  love.mouse.setGrabbed(
    libs.hump.gamestate.current() == states.mission and
    not states.mission.vn:getRun() and
    love.window.hasFocus()
  )
end

function love.quit()
  settings:save()
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

function playSFX(source,variation)
  local current_source
  if type(source) == "table" then
    for _,v in pairs(source) do
      v:stop()
    end
    current_source = source[math.random(#source)]
  else
    source:stop()
    current_source = source
  end
  current_source:setVolume(settings:read("sfx_vol"))
  if variation then
    current_source:setPitch( (1-variation)+math.random()*variation*2 )
  end
  love.audio.play(current_source)
end

function loopSFX(source,variation)
  local current_source = type(source) == "table" and source[math.random(#source)] or source
  current_source:setVolume(settings:read("sfx_vol"))
  if not current_source:isPlaying( ) then
    if variation then
      current_source:setPitch( (1-variation)+math.random()*variation*2 )
    end
    love.audio.play(current_source)
  end
end

function getFileName(i)
  local _,_,fname,extension = i:find("^(.+)%.(.*)")
  return fname
end

function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end
