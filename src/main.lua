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
      mpgamemodes = require"libs.mpgamemodes",
      mpserverlist = require"libs.mpserverlist",
      json = require"libs.json",
      ai = require"libs.ai",
      bump = require"libs.bump",
    }

    libs.levelshared = require"libs.levelshared"
    libs.mppresets = require"libs.mppresets"

    libs.objectrenderer.load(false)
    libs.bulletrenderer.load(false)
    libs.mpgamemodes.load(false)
    libs.mpserverlist.load(false)

    states = {
      server = require "states.server",
    }
    libs.hump.gamestate.registerEvents()
    libs.hump.gamestate.switch(states.server)
    return
  end

  loader = require"libs.loader".new{onDone=function()
    libs.hump.gamestate.switch(states.splash)
  end}

  loader:add("window icon",function()
    love.window.setIcon(love.image.newImageData("assets/icons/rcs_512.png"))
  end)

  loader:add("tooltip edge",function()
    tooltipf_edge = love.graphics.newImage("assets/hud/tooltip_edge.png")
  end)

  loader:add("fonts",function()
    function makeFonts()
      fonts = {
        default = love.graphics.newFont("assets/fonts/Roboto-Regular.ttf",16),
        small = love.graphics.newFont("assets/fonts/Roboto-Regular.ttf",12),
        large = love.graphics.newFont("assets/fonts/Roboto-Regular.ttf",24),
        window_title = love.graphics.newFont("assets/fonts/ExpletusSans-Bold.ttf",20),
        title = love.graphics.newFont("assets/fonts/ExpletusSans-Bold.ttf",64),
        menu = love.graphics.newFont("assets/fonts/Roboto-Regular.ttf",20),
        submenu = love.graphics.newFont("assets/fonts/Roboto-Regular.ttf",16),
        vn_title = love.graphics.newFont("assets/fonts/ExpletusSans-Bold.ttf",64),
        vn_name = love.graphics.newFont("assets/fonts/ExpletusSans-Bold.ttf",48),
        vn_text = love.graphics.newFont("assets/fonts/Roboto-Regular.ttf",24),
        vn_italic = love.graphics.newFont("assets/fonts/Roboto-RegularItalic.ttf",24),
        vn_info = love.graphics.newFont("assets/fonts/Roboto-Regular.ttf",16),
        fallback = love.graphics.newFont("assets/fonts/NovaMono.ttf",16),
      }
    end
    makeFonts()
    love.graphics.setFont(fonts.default)
    fonts.default:setFallbacks(fonts.fallback)
  end)

  libs = {
    hump = {
      gamestate = require "libs.gamestate",
      camera = require "libs.camera",
    },
    acf = {
      validator=require "libs.acf.validator",
    },
    cursor = require"libs.cursor",
    pcb = require"libs.progresscirclebar",
    system = require"libs.system",
    moonshine = require"libs.moonshine",
    md2campaign = require"libs.md2campaign",
    scanlib = require"libs.scanlib",
    reflowprint = require"libs.reflowprint",
  }

  loader:add("scanlib",function()
    libs.scanlib.load()
  end)

  loader:add("lib dependencies",function()
    libs.gettext = require"libs.gettextlib"
    libs.i18n = require"libs.i18n"
    libs.lovernet = require"libs.lovernet.lovernet"
    libs.bitser = require"libs.lovernet.bitser"
    libs.ai = require"libs.ai"
    libs.slider = require"libs.slider"
  end)

  loader:add("localizations",function()
    local loc_data = libs.gettext.decode(love.filesystem.read("assets/loc/en.po"))
    for i,v in pairs(loc_data) do
      local newstr = v.str:gsub([[\n]],"\n"):gsub([[\"]],"\"")
      libs.i18n.set('en.'..v.id,newstr)
    end
  end)

  local lib_dir = "libs/"
  for _,filename in pairs(love.filesystem.getDirectoryItems(lib_dir)) do
    if love.filesystem.isFile( lib_dir..filename ) then
      loader:add(file.name(filename),function()
        if libs[file.name(filename)] == nil then
          libs[file.name(filename)] = require(lib_dir..(file.name(filename)))
        end
      end)
    end
  end

  loader:add("backgrounds",function()
    libs.backgroundlib.load()
  end)

  loader:add("renderers",function()
    libs.objectrenderer.load(true)
    libs.bulletrenderer.load(true)
  end)

  loader:add("game modes",function()
    libs.mpgamemodes.load(true)
  end)

  loader:add("server list",function()
    libs.mpserverlist.load(true)
  end)

  loader:add("some space",function()
    libs.stars:loadSpace()
  end)
  loader:add("some stars",function()
    libs.stars:loadStars0()
  end)
  loader:add("some more stars",function()
    libs.stars:loadStars1()
  end)
  loader:add("even more stars",function()
    libs.stars:load(false)
  end)

  loader:add("sfx",function()
    libs.sfx.load()
  end)

  states = {
    load = require "states.load",
    server = require"states.server",
  }

  loader:add("gamestates",function()
    states = {
      load = require "states.load",
      splash = require "states.splash",
      menu = require "states.menu",
      options = require "states.options",
      credits = require "states.credits",
      debug = require "states.debug",
      dynamicmusic = require "states.dynamicmusic",
      client = require"states.client",
      server = require"states.server",
    }
  end)

  loader:add("cursors",function()
    libs.cursor.add("default","assets/hud/cursors/default.png")
    libs.cursor.add("player","assets/hud/cursors/player.png")
    -- libs.cursor.add("enemy","assets/hud/cursors/enemy.png")
    libs.cursor.add("neutral","assets/hud/cursors/neutral.png")

    -- libs.cursor.add("crew","assets/hud/cursors/crew.png")
    -- libs.cursor.add("material","assets/hud/cursors/material.png")
    -- libs.cursor.add("ore","assets/hud/cursors/ore.png")
    --
    -- libs.cursor.add("follow","assets/hud/cursors/follow.png")
    -- libs.cursor.add("shoot","assets/hud/cursors/shoot.png")
    -- libs.cursor.add("takeover","assets/hud/cursors/takeover.png")

    libs.cursor.change("default")
    libs.cursor.isLoaded = true
    libs.cursor.mode(settings:read("mouse_draw_mode"))
  end)

  loader:add("args",function()
  local version_server_check = true
    for i,v in pairs(arg) do
      if states[v] then
        target_state = states[v]
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
  end)

  -- this hack allows me to re-order when gamestate runs draw
  local callbacks = {'errhand', 'update'} -- no draw
  for k in pairs(love.handlers) do
    callbacks[#callbacks+1] = k
  end
  libs.hump.gamestate.registerEvents(callbacks)
  libs.hump.gamestate.switch(target_state or states.load)
end

function love.resize()
  if libs.stars then libs.stars:reload() end
  if states.client then states.client:resize() end
  if GLOBAL_SHADER then
    GLOBAL_SHADER()
  end
end

function love.keypressed(key)
  if key == "f5" then
    debug_hide_hud = not debug_hide_hud
  end
  if key == "f12" then
    local dname = "screenshots"
    if not love.filesystem.exists(dname) then
      love.filesystem.createDirectory(dname)
    end
    local fname = dname .. "/" .. os.time() .. '.png'
    if not love.filesystem.exists(fname) then
      local screenshot = love.graphics.newScreenshot();
      screenshot:encode('png', fname);
      local full = love.filesystem.getSaveDirectory() .. "/" .. fname
      libs.system:set("Screenshot @ " .. full, 3)
    end
  end
end

function love.update(dt)
  if libs.net then libs.net.clearCache() end
  if not headless then
    if libs.cursor.isLoaded then
      if love.mouse.isDown(1) then
        libs.cursor.change("player")
      elseif love.mouse.isDown(2) then
        libs.cursor.change("neutral")
      else
        libs.cursor.change("default")
      end
    end
    libs.cursor.update(dt)
    love.mouse.setGrabbed(
      (
        (libs.hump.gamestate.current() == states.client and not states.client.menu_enabled)
      ) and love.window.hasFocus()
    )
    libs.system:update(dt)
  end
  if libs.tooltip then
    libs.tooltip.update(dt)
  end
  if states.server.run_localhost then
    states.server:update(dt)
  end
end

function love.draw()
  if GLOBAL_SHADER_OBJ then
    GLOBAL_SHADER_OBJ(love.real_draw)
  else
    love.real_draw()
  end
end

function love.real_draw()
  libs.hump.gamestate.current():draw()
  libs.cursor.draw()
  libs.system:draw()
  if libs.tooltip then
    libs.tooltip.draw()
  end
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
  if (type(x)=="table") then
    x,y,w,h = x.x,x.y,x.width,x.height
  end
  local old_color = {love.graphics.getColor()}
  love.graphics.setColor(255,0,0)
  love.graphics.rectangle("line",x+0.5,y+0.5,w,h)
  love.graphics.line(x,y,x+w,y+h)
  love.graphics.line(x+w,y,x,y+h)
  love.graphics.setColor(old_color)
end

function tooltipf(text,ox,oy,ow,align)
  if debug_hide_hud then return end
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
  if hours > 0 then
    return string.format("%02d:%02d:%02d",hours,minutes,seconds)
  else
    return string.format("%02d:%02d",minutes,seconds)
  end
end

function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    -- setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function deencode(self,input)
  return deepcopy(input)
end

-- absorb slave into master
function absorb(master,slave)
  for i,_ in pairs(slave) do
    if type(master[i]) == "table" and type(slave[i]) == "table" then
      absorb(master[i],slave[i])
    else
      master[i]=slave[i]
    end
  end
  return master
end

function print_r (t,indent)
  indent = indent or ""
  if (type(t)=="table") then
    for pos,val in pairs(t) do
      if (type(val)=="table") then
        print(indent.."["..pos.."] "..tostring(t).." => {")
        print_r(val,indent..string.rep(" ",2))
        print(indent..string.rep(" ",0).."}")
      else
        print(indent.."["..pos.."] => "..tostring(val))
      end
    end
  else
    print(indent..tostring(t))
  end
end
