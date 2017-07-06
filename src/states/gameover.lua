local state = {}

function state:init()
  self.text_win = libs.i18n('gameover.win')
  self.text_lose = libs.i18n('gameover.lose')
end

function state:enter()

  states.menu.music.title:play()
  states.menu.music.game:stop()

  self.text = (self.win and self.text_win or self.text_lose).."\n\n"..
    states.mission.score:render()

  self.escape_delay_timer = 0
  self.escape_delay_max = 0.5
  self.fade_dt = 1
  self.fade_t = 1

  -- TODO, SCALE THIS TO SCORE
  local tree_points = settings:read("tree_points")
  settings:write("tree_points",tree_points+5)
end

function state:update(dt)
  self.escape_delay_timer = self.escape_delay_timer + dt
  self.fade_dt = math.max(0,self.fade_dt-dt)
end

function state:keypressed(key)
  if self.escape_delay_timer > self.escape_delay_max then
    state:getoutofhere()
  end
end

function state:mousereleased(x,y,b)
  if self.escape_delay_timer > self.escape_delay_max then
    state:getoutofhere()
  end
end

function state:getoutofhere()
  libs.hump.gamestate.switch(self.win and states.credits or states.menu)
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
