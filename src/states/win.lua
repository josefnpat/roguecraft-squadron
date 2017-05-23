local state = {}

function state:enter()
  self.text = "You have defeated the alien invasion!\nYou win!\n\n"..
    states.mission.score:render()

  self.scroll_speed = 8

  self.escape_delay_timer = 0
  self.escape_delay_max = 0.5
  self.fade_dt = 1
  self.fade_t = 1
end

function state:update(dt)
  self.escape_delay_timer = self.escape_delay_timer + dt
  self.fade_dt = math.max(0,self.fade_dt-dt)
end

function state:keypressed(key)
  if self.escape_delay_timer > self.escape_delay_max then
    libs.hump.gamestate.switch(states.credits)
  end
end

function state:mousereleased(x,y,b)
  if self.escape_delay_timer > self.escape_delay_max then
    libs.hump.gamestate.switch(states.credits)
  end
end

function state:draw()

  libs.stars:draw()
  libs.stars:drawPlanet()

  love.graphics.setFont(fonts.menu)
  dropshadowf(self.text,0,love.graphics:getHeight()/4,love.graphics:getWidth(),"center")
  love.graphics.setFont(fonts.default)

  local percent = self.fade_dt / self.fade_t
  love.graphics.setColor(0,0,0,255*percent)
  love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
  love.graphics.setColor(255,255,255)

end

return state
