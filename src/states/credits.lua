credits = {}

function credits:init()
  self.mss = love.graphics.newImage("assets/credits/mss.png")
  self.enp = love.graphics.newImage("assets/credits/enp.png")
  self.ai = love.graphics.newImage("assets/credits/ai.png")
  self.bd = love.graphics.newImage("assets/credits/bd.png")
  self.delmun = love.graphics.newImage("assets/credits/delmun.png")

  self.vivid = {
    init = function(self)
      self.current = 1
      self.dt = 0
      self.t = 1/(170/60*2)
      self.images = {
        love.graphics.newImage("assets/credits/vivid1.png"),
        love.graphics.newImage("assets/credits/vivid2.png"),
        love.graphics.newImage("assets/credits/vivid1.png"),
        love.graphics.newImage("assets/credits/vivid3.png"),
      }
    end,
    draw = function(self,x,y)
      love.graphics.draw(self.images[self.current],x,y)
    end,
    getWidth = function(self)
      return self.images[self.current]:getWidth()
    end,
    getHeight = function(self)
      return self.images[self.current]:getHeight()
    end,
    getImage = function(self)
      return self.images[self.current]
    end,
    update = function(self,dt)
      self.dt = self.dt + dt
      if self.dt >= self.t then
        self.dt = self.dt - self.t
        self.current = self.current + 1
        if self.images[self.current] == nil then
          self.current = 1
        end
      end
    end
  }
  self.vivid:init()

  self.testers = {"Peter Oswald","Ashley Shuster","ByteDesigning","Vivid","EntranceJew","Forer"}
  -- Thank you so much whiteland92!!! <3
  self.ibtwitch = {"icecooltea","whiteland92"}
  self.twitch = {"bartbes","whitebot_","ashlon23","unekpl","hartlomiej",
    "dozybrit","mcht2k","whiteland92","ikroth","human_regret","shakesoda",
    "xghozt55","icecooltea","animegrillz","feilkin","frozenzerker","cerdus",
    "davidgamedev","alloyed","gjallar_","fooblaz","statiyx","skaitiklis",
    "jambis2","raycatrakittra","karai17","erikskogl","lewn1e","nzxlive",
    "murii97","urbanbanchou","shouldbereading","returnnil","mightygamer",
    "raxe88","bytedesigning",
  }

end

function credits:enter()

  self.data = {}

  table.insert(self.data,{
    data = libs.i18n('disclaimer.pre'),
    font = fonts.window_title,
    padding = 32,
  })
  table.insert(self.data,{
    data = libs.i18n('disclaimer.'..math.random(1,13)),
  })

  table.insert(self.data,{
    data = libs.i18n('credits.title'),
    font = fonts.window_title,
    padding = 32,
  })
  table.insert(self.data,{
    data = [[Josef Patoprsty (@josefnpat) — Code, Art, Design, Voice Talent
Ashley Hooper (@ByteDesigning) — Code, Art
Ashley Schuster (SnowSchu) — Marketing and QA
Ran Schonewille (audio-interactive.com) — Music Composer
Noyemi Karlaite (@NoyemiK) — Character Art
Laura Vk (Solsforest) — Art, Voice Talent
Arjan Vk (Vivid) — Code, SFX, Voice Talent
Mauricyo Furtado (@eternalnightpro) — SFX
Ethan Blackley — Video Marketing]]
  })

  table.insert(self.data,{
    data = libs.i18n('credits.playtesters'),
    font = fonts.window_title,
    padding = 32,
  })
  for _,v in pairs(self.testers) do
    table.insert(self.data,{
      data = v,
    })
  end

  table.insert(self.data,{
    data = libs.i18n('credits.ibtwitch'),
    font = fonts.window_title,
    padding = 32,
  })
  for _,v in pairs(self.ibtwitch) do
    table.insert(self.data,{
      data = v,
    })
  end

  table.insert(self.data,{
    data = libs.i18n('credits.twitch'),
    font = fonts.window_title,
    padding = 32,
  })
  table.insert(self.data,{
    data = table.concat(self.twitch," - "),
  })

  table.insert(self.data,{data = self.ai,})
  table.insert(self.data,{data = self.enp,})
  table.insert(self.data,{data = self.bd,})
  table.insert(self.data,{data = self.vivid,})
  table.insert(self.data,{data = self.delmun,})
  table.insert(self.data,{data = self.mss,})
  table.insert(self.data,{data = libs.i18n('credits.thanks'),})

  self.y = love.graphics:getHeight()

  self.escape_delay_timer = 0
  self.escape_delay_max = 0.5

  self.padding = love.graphics.getWidth()/4

end

function credits:update(dt)

  if not love.keyboard.isDown("space") then
    self.scroll_speed = 32
  else
    self.scroll_speed = 128
end

  self.y = self.y - dt * self.scroll_speed
  self.escape_delay_timer = self.escape_delay_timer + dt

  for _,v in pairs(self.data) do
    if type(v.data) == "table" then
      v.data:update(dt)
    end
  end

end

function credits:keypressed(key)

  if key == "escape" then
    if self.escape_delay_timer > self.escape_delay_max then
      libs.hump.gamestate.switch(states.menu)
    end
  end
end

function credits:mousereleased(x,y,b)
  if self.escape_delay_timer > self.escape_delay_max then
    libs.hump.gamestate.switch(states.menu)
  end
end

function credits:draw()

  libs.stars:draw()
  libs.stars:drawPlanet()

  local maxwidth = love.graphics:getWidth()-self.padding*2
  local cury = self.y
  for _,line in pairs(self.data) do
    if type(line.data) == "string" then -- text
      if line.padding then
        cury = cury + line.padding
      end
      local font = line.font or fonts.menu
      love.graphics.setFont(font)
      local width, wrappedtext = font:getWrap( line.data, maxwidth )
      dropshadowf(line.data,self.padding,cury,maxwidth,"center")
      cury = cury + #wrappedtext*font:getHeight()
      if line.padding then
        cury = cury + line.padding
      end
    elseif type(line.data) == "userdata" then -- assuming image
      cury = cury + 32
      love.graphics.draw(line.data,(love.graphics.getWidth()-line.data:getWidth())/2,cury)
      cury = cury + line.data:getHeight() + 32
    elseif type(line.data) == "table" then -- assuming custom object
      cury = cury + 32
      love.graphics.draw(
        line.data:getImage(),
        (love.graphics.getWidth()-line.data:getWidth())/2,
        cury)
      cury = cury + line.data:getHeight() + 32
    else
      print('unhandled line data detected:',type(line.data))
    end
  end
  love.graphics.setFont(fonts.default)
end

return credits
