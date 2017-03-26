local state = {}

function state:enter()
  self.text = "You and your crew have been lost to the void of space.\nYou Lose.\n\n"..
    states.mission.score:render()

  self.escape_delay_timer = 0
  self.escape_delay_max = 0.5
end

function state:update(dt)
  self.escape_delay_timer = self.escape_delay_timer + dt
end

function state:keypressed(key)
  if self.escape_delay_timer > self.escape_delay_max then
    libs.hump.gamestate.switch(states.menu)
  end
end

function state:mousereleased(x,y,b)
  if self.escape_delay_timer > self.escape_delay_max then
    libs.hump.gamestate.switch(states.menu)
  end
end

function state:draw()

  libs.stars:draw()
  libs.stars:drawPlanet()

  love.graphics.setFont(fonts.menu)
  dropshadowf(self.text,0,love.graphics:getHeight()/4,love.graphics:getWidth(),"center")
  love.graphics.setFont(fonts.default)
end

return state
