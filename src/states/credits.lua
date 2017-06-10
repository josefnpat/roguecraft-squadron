credits = {}

function credits:enter()
  self.text =
  "CREDITS:\n" ..
  "\n" ..
  "Josef Patoprsty (@josefnpat) — Code, Art, Design, Voice Talent\n" ..
  "Ashley Hooper (@ByteDesigning) — Art\n" ..
  "Mauricyo Furtado (@eternalnightpro) — Music, SFX\n" ..
  "Laura Vk (Solsforest) — Art, Voice Talent\n" ..
  "Arjan Vk (Vivid) — Code, SFX, Voice Talent\n" ..
  "Ethan Blackley — Video Marketing\n" ..
  "\n\n\n"

  self.testers = {"Forer","EntranceJew","ByteDesigning","Vivid"}
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

  self.text = self.text .. "Playtesters:\n\n"
  for i,v in pairs(self.testers) do
    self.text = self.text .. v .. "\n"
  end

  self.text = self.text .. "\nTwitch Internet Buck Millionaires:\n\n"
  for i,v in pairs(self.ibtwitch) do
    self.text = self.text .. v .. "\n"
  end

  self.text = self.text .. "\nTwitch Peeps:\n\n"
  self.text = self.text .. table.concat(self.twitch," - ")

  self.text = self.text .. "\n\n\nThanks for playing!\n"

  self.y = love.graphics:getHeight()
  
  self.escape_delay_timer = 0
  self.escape_delay_max = 0.5
end

function credits:update(dt)

if not love.keyboard.isDown("space") then 
    self.scroll_speed = 32
  else
    self.scroll_speed = 128
end

  self.y = self.y - dt * self.scroll_speed
  self.escape_delay_timer = self.escape_delay_timer + dt
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

  love.graphics.setFont(fonts.menu)
  dropshadowf(self.text,0,self.y,love.graphics:getWidth(),"center")
  love.graphics.setFont(fonts.default)
end

return credits
