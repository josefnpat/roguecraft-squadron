credits = {}

function credits:enter()
  self.text =
  "CREDITS:\n" ..
  "\n" ..
  "Josef Patoprsty (@josefnpat) — Code, Art, Design, Voice Talent\n" ..
  "Ashley Hooper (@ByteDesigning) — Art\n" ..
  "Mauricyo Furtado (@eternalnightpro) — Music\n" ..
  "Laura Vk (Solsforest) — Art, Voice Talent\n" ..
  "Arjan Vk (Vivid) — Code, SFX, Voice Talent \n" ..
  "\n\n\n"

  self.testers = {"Forer","EntranceJew","@ByteDesigning","Vivid"}
  -- Thank you so much whiteland92!!! <3
  self.ibtwitch = {"icecooltea","whiteland92"}
  self.twitch = {}

  self.text = self.text .. "Playtesters:\n\n"
  for i,v in pairs(self.testers) do
    self.text = self.text .. v .. "\n"
  end

  self.text = self.text .. "Twitch Internet Buck Millionaries:\n\n"
  for i,v in pairs(self.ibtwitch) do
    self.text = self.text .. v .. "\n"
  end

  self.text = self.text .. "Twitch Peeps:\n\n"
  for i,v in pairs(self.twitch) do
    self.text = self.text .. v .. "\n"
  end

  self.text = self.text .. "\n\n\nThanks for playing!\n"

  self.space = bg.space

  self.stars0 = bg.stars0
  self.stars0:setWrap("repeat","repeat")
  self.stars0_quad = love.graphics.newQuad(0, 0,
  1280+self.stars0:getWidth(), 720+self.stars0:getHeight(),
    self.stars0:getWidth(), self.stars0:getHeight())

  self.stars1 = bg.stars1
  self.stars1:setWrap("repeat","repeat")
  self.stars1_quad = love.graphics.newQuad(0, 0,
    1280+self.stars1:getWidth(), 720+self.stars1:getHeight(),
    self.stars1:getWidth(), self.stars1:getHeight())

  self.background_scroll_speed = 4

  self.y = love.graphics:getHeight()
  self.scroll_speed = 32

  self.escape_delay_timer = 0
  self.escape_delay_max = 0.5
end

function credits:update(dt)
  self.y = self.y - dt * self.scroll_speed
  self.escape_delay_timer = self.escape_delay_timer + dt
end

function credits:keypressed(key)
  if self.escape_delay_timer > self.escape_delay_max then
    libs.hump.gamestate.switch(states.menu)
  end
end

function credits:mousereleased(x,y,b)
  if self.escape_delay_timer > self.escape_delay_max then
    libs.hump.gamestate.switch(states.menu)
  end
end

function credits:draw()

  love.graphics.draw(self.space,0,0)

  love.graphics.setBlendMode("add")

  love.graphics.draw(self.stars0, self.stars0_quad,
    0,
    -self.stars0:getHeight()+((love.timer.getTime()*self.background_scroll_speed)%self.stars0:getHeight()) )

  love.graphics.draw(self.stars1, self.stars1_quad,
    0,
    -self.stars1:getHeight()+((love.timer.getTime()/2*self.background_scroll_speed)%self.stars1:getHeight()) )

  love.graphics.setBlendMode("alpha")
  love.graphics.setFont(fonts.menu)
  dropshadowf(self.text,0,self.y,love.graphics:getWidth(),"center")
  love.graphics.setFont(fonts.default)
end

return credits
