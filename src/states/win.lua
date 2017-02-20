local state = {}

function state:enter()
  self.text = "You have defeated the alien invasion!\nYou win!"
  
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
  self.scroll_speed = 8
  
  self.escape_delay_timer = 0
  self.escape_delay_max = 0.5
end

function state:update(dt)
  self.escape_delay_timer = self.escape_delay_timer + dt
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
  dropshadowf(self.text,0,love.graphics:getHeight()/2,love.graphics:getWidth(),"center")
  love.graphics.setFont(fonts.default)
end

return state
