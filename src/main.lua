function love.load(arg)

  -- Thanks @bartbes! fixes cygwin buffer
  io.stdout:setvbuf("no")

  math.randomseed(os.time())

  if headless then
    libs = {
      hump = {
        gamestate = require "libs.gamestate",
      },
      lovernet = require"libs.lovernet.lovernet",
      bitser = require"libs.lovernet.bitser",
      net = require"libs.net",
      objectrenderer = require"libs.objectrenderer",
      researchrenderer = require"libs.researchrenderer",
      bulletrenderer = require"libs.bulletrenderer",
      ai = require"libs.ai",
      mppresets = require"libs.mppresets",
    }

    libs.objectrenderer.load(false)
    libs.researchrenderer.load(false)
    libs.bulletrenderer.load(false)

    states = {
      server = require "states.server",
    }
    libs.hump.gamestate.registerEvents()
    libs.hump.gamestate.switch(states.server)
    return
  end

  love.window.setIcon(love.image.newImageData("assets/icon.png"))

  tooltipf_edge = love.graphics.newImage("assets/hud/tooltip_edge.png")

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
      correct = love.audio.newSource("assets/vn/adj/audio/correct.ogg","stream"),
      incorrect = love.audio.newSource("assets/vn/adj/audio/incorrect.ogg","stream"),
      warning = love.audio.newSource("assets/vn/adj/audio/warning.ogg","stream"),
      line1 = love.audio.newSource("assets/vn/adj/audio/line1.ogg","stream"),
      line2 = love.audio.newSource("assets/vn/adj/audio/line2.ogg","stream"),
      line3 = love.audio.newSource("assets/vn/adj/audio/line3.ogg","stream"),
      line4 = love.audio.newSource("assets/vn/adj/audio/line4.ogg","stream"),
      line5 = love.audio.newSource("assets/vn/adj/audio/line5.ogg","stream"),
      line6 = love.audio.newSource("assets/vn/adj/audio/line6.ogg","stream"),
      line7 = love.audio.newSource("assets/vn/adj/audio/line7.ogg","stream"),
      line8 = love.audio.newSource("assets/vn/adj/audio/line8.ogg","stream"),
      --line9 = love.audio.newSource("assets/vn/adj/audio/line9.ogg","stream"),
    },
    com = {
      line1 = love.audio.newSource("assets/vn/com/audio/line1.ogg","stream"),
      line2 = love.audio.newSource("assets/vn/com/audio/line2.ogg","stream"),
      line3 = love.audio.newSource("assets/vn/com/audio/line3.ogg","stream"),
      line4 = love.audio.newSource("assets/vn/com/audio/line4.ogg","stream"),
      line5 = love.audio.newSource("assets/vn/com/audio/line5.ogg","stream"),
      line6 = love.audio.newSource("assets/vn/com/audio/line6.ogg","stream"),
      line7 = love.audio.newSource("assets/vn/com/audio/line7.ogg","stream"),
      line8 = love.audio.newSource("assets/vn/com/audio/line8.ogg","stream"),
      line9 = love.audio.newSource("assets/vn/com/audio/line9.ogg","stream"),
      line10 = love.audio.newSource("assets/vn/com/audio/line10.ogg","stream"),
      line11 = love.audio.newSource("assets/vn/com/audio/line11.ogg","stream"),
      line12 = love.audio.newSource("assets/vn/com/audio/line12.ogg","stream"),
      line13 = love.audio.newSource("assets/vn/com/audio/line13.ogg","stream"),
      line14 = love.audio.newSource("assets/vn/com/audio/line14.ogg","stream"),
      line15 = love.audio.newSource("assets/vn/com/audio/line15.ogg","stream"),
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
      default = love.graphics.newFont("assets/fonts/Yantramanav-Regular.ttf",16),
      small = love.graphics.newFont("assets/fonts/Yantramanav-Regular.ttf",12),
      large = love.graphics.newFont("assets/fonts/Yantramanav-Regular.ttf",24),
      window_title = love.graphics.newFont("assets/fonts/ExpletusSans-Bold.ttf",20),
      title = love.graphics.newFont("assets/fonts/ExpletusSans-Bold.ttf",64),
      menu = love.graphics.newFont("assets/fonts/Yantramanav-Regular.ttf",20),
      vn_name = love.graphics.newFont("assets/fonts/Yantramanav-Regular.ttf",48),
      vn_text = love.graphics.newFont("assets/fonts/Yantramanav-Regular.ttf",24),
      vn_info = love.graphics.newFont("assets/fonts/Yantramanav-Regular.ttf",16),
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
    healthbar = require"libs.healthbar",
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
    i18n = require"libs.i18n",
    gettext = require"libs.gettextlib",
    cursor = require"libs.cursor",
    version = require"libs.version",
    camera_edge = require"libs.camera_edge",
    bar = require"libs.bar",
    lovernet = require"libs.lovernet.lovernet",
    lovernetprofiler = require"libs.lovernetprofiler",
    bitser = require"libs.lovernet.bitser",
    selection = require"libs.selection",
    buildqueue = require"libs.buildqueue",
    net = require"libs.net",
    objectrenderer = require"libs.objectrenderer",
    researchrenderer = require"libs.researchrenderer",
    bulletrenderer = require"libs.bulletrenderer",
    minimap = require"libs.minimap",
    resources = require"libs.resources",
    fow = require"libs.fow",
    demo = require"libs.demo",
    planets = require"libs.planets",
    matrixpanel = require"libs.matrixpanel",
    actionpanel = require"libs.actionpanel",
    explosions = require"libs.explosions",
    gather = require"libs.gather",
    moveanim = require"libs.moveanim",
    sfx = require"libs.sfx",
    controlgroups = require"libs.controlgroups",
    chat = require"libs.chat",
    button = require"libs.button",
    slider = require"libs.slider",
    dynamicaudio = require"libs.dynamicaudio",
    mpdisconnect = require"libs.mpdisconnect",
    mpconnect = require"libs.mpconnect",
    mpresearch = require"libs.mpresearch",
    mpconnectplayer = require"libs.mpconnectplayer",
    gamestatus = require"libs.gamestatus",
    ring = require"libs.ring",
    ai = require"libs.ai",
    mppresets = require"libs.mppresets",
    loading = require"libs.loading",
    picocam = require"libs.picocam",
    points = require"libs.points",
    matchstats = require"libs.matchstats",
  }

  libs.objectrenderer.load(true)
  libs.researchrenderer.load(true)
  libs.bulletrenderer.load(true)
  libs.sfx.load()

  states = {
    splash = require "states.splash",
    menu = require "states.menu",
    pause = require "states.pause",
    options = require "states.options",
    gameover = require"states.gameover",
    tree = require"states.tree",
    mission = require "states.mission",
    credits = require "states.credits",
    disclaimer = require "states.disclaimer",
    debug = require "states.debug",
    dynamicmusic = require "states.dynamicmusic",
    client = require"states.client",
    server = require"states.server",
  }

  local loc_data = libs.gettext.decode(love.filesystem.read("assets/loc/en.po"))

  --local loc_i18n = {}
  for i,v in pairs(loc_data) do
    local newstr = v.str:gsub([[\n]],"\n"):gsub([[\"]],"\"")
    libs.i18n.set('en.'..v.id,newstr)
  end

  libs.cursor.add("default","assets/hud/cursors/default.png")
  libs.cursor.add("player","assets/hud/cursors/player.png")
  libs.cursor.add("enemy","assets/hud/cursors/enemy.png")
  libs.cursor.add("neutral","assets/hud/cursors/neutral.png")

  libs.cursor.add("crew","assets/hud/cursors/crew.png")
  libs.cursor.add("material","assets/hud/cursors/material.png")
  libs.cursor.add("ore","assets/hud/cursors/ore.png")

  libs.cursor.add("follow","assets/hud/cursors/follow.png")
  libs.cursor.add("shoot","assets/hud/cursors/shoot.png")
  libs.cursor.add("takeover","assets/hud/cursors/takeover.png")

  libs.cursor.change("default")
  libs.cursor.mode(settings:read("mouse_draw_mode"))

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
      settings:write("tree_points",9000)
    end
    if v == "debug" then
      debug_mode = true
    end
    if v == "nocheck" then
      version_server_check = false
    end
    if v == "nodraw" then
      function love.graphics.draw(...)
        local arg={...}
        if arg[2] and type(arg[2]) == "userdata" then
          --love.graphics.drawq(unpack(arg))
        else
          love.graphics.drawd(unpack(arg))
        end
      end
      function love.graphics.drawd(drawable, x, y, r, sx, sy, ox, oy, kx, ky )
        local nx,ny = (x or 0)-(ox or 0),(y or 0)-(oy or 0)
        local nw,nh = drawable:getWidth()*(sx or 1),drawable:getHeight()*(sy or 1)
        if r and r ~= 0 then
          love.graphics.circle("line",nx+nw/2,ny+nh/2,math.min(nw,nh)/2)
        else
          love.graphics.rectangle("line",nx,ny,nw,nh)
        end
      end
    end
  end

  if version_server_check then
    local http = require"socket.http"
    local version_server_payload = libs.json.encode({count=git_count,hash=git_hash})
    local version_server_url = "http://50.116.63.25/roguecraftsquadron.com/version.php?i="
    local r,e = http.request(version_server_url..version_server_payload)
    version_server = e == 200 and libs.json.decode(r) or nil
  end

  -- this hack allows me to re-order when gamestate runs draw
  local callbacks = {'errhand', 'update'} -- no draw
  for k in pairs(love.handlers) do
    callbacks[#callbacks+1] = k
  end
  libs.hump.gamestate.registerEvents(callbacks)
  libs.hump.gamestate.switch(target_state or states.splash)
end

function love.resize()
  libs.stars:reload()
  states.mission:resize()
  states.client:resize()
end

function love.update(dt)
  if not headless then
    libs.cursor.update(dt)
    love.mouse.setGrabbed(
      (
        libs.hump.gamestate.current() == states.mission or
        (libs.hump.gamestate.current() == states.client and not states.client.menu_enabled)
      ) and love.window.hasFocus()
    )
  end
  if states.server.run_localhost then
    states.server:update(dt)
  end
end

function love.draw()
  libs.hump.gamestate.current():draw()
  libs.cursor.draw()
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

function tooltipbg(ox,oy,width,oh,c1,c2)
  c1 = c1 or {15,63,63,256*7/8}
  c2 = c2 or {0,255,255}
  love.graphics.setColor(c1)
  love.graphics.rectangle("fill",ox,oy,width,oh)
  love.graphics.setColor(c2)
  love.graphics.draw(tooltipf_edge,ox,oy)
  love.graphics.draw(tooltipf_edge,ox+width,oy,math.pi/2)
  love.graphics.draw(tooltipf_edge,ox+width,oy+oh,math.pi)
  love.graphics.draw(tooltipf_edge,ox,oy+oh,-math.pi/2)
end

function debugrect(x,y,w,h)
  local old_color = {love.graphics.getColor()}
  love.graphics.setColor(255,0,0)
  love.graphics.rectangle("line",x+0.5,y+0.5,w,h)
  love.graphics.line(x,y,x+w,y+h)
  love.graphics.line(x+w,y,x,y+h)
  love.graphics.setColor(old_color)
end

function tooltipf(text,ox,oy,ow,align)
  local padding = 8

  local x = ox + padding
  local y = oy + padding
  local w = ow - padding*2
  local color = {love.graphics.getColor()}
  local font = love.graphics.getFont()
  local width,wrappedtext = font:getWrap(text,w)
  local h = #wrappedtext*font:getHeight()
  local oh = h + padding*2

  local offsetx = 0
  -- dirty hack
  if not align and width < w then
    offsetx = w - width
  end

  tooltipbg(ox+offsetx,oy,width+padding*2,oh)

  love.graphics.setColor(0,0,0,191)
  love.graphics.printf(text,x+offsetx+2,y+2,w)
  love.graphics.setColor(color)
  love.graphics.printf(text,x+offsetx,y,w)
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

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function compareIndexed(t1,t2)
  local t1_count = 0
  for _,_ in pairs(t1) do t1_count = t1_count + 1 end
  local t2_count = 0
  for _,_ in pairs(t2) do t2_count = t2_count + 1 end
  if t1_count ~= t2_count then
    return false
  end
  for i,v in pairs(t1) do
    if type(v) == "table" then
      if type(t2[i]) ~= "table" then
        return false
      end
      local valid_left = compareIndexed(v,t2[i])
      if not valid_left then
        return false
      end
    else -- numbers, strings, functions, etc
      if t2[i] ~= v then
        return false
      end
    end
  end
  return true
end

file = {}

function file.name(url)
  return url:match("(.+)%..+")
end

function file.extension(url)
  return url:match("[^.]+$")
end

function file.getAllDirectoryItems(dir)
  local items = {}
  for _,item in pairs(love.filesystem.getDirectoryItems(dir)) do
    table.insert(items,dir..item)
  end
  local release_dir = "release/"..dir
  if love.filesystem.isDirectory(release_dir) then
    for _,item in pairs(love.filesystem.getDirectoryItems(release_dir)) do
      table.insert(items,release_dir..item)
    end
  end
  return items
end

function isRelease()
  return love.filesystem.isDirectory("release")
end

function starts_with(str, start)
   return str:sub(1, #start) == start
end

function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function seconds_to_clock(time)
  local hours = math.floor(time/3600)
  local minutes = math.floor(math.mod(time,3600)/60)
  local seconds = math.floor(math.mod(time,60))
  return string.format("%02d:%02d:%02d",hours,minutes,seconds)
end
