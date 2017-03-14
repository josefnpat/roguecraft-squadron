local state = {}

function state:init()
  self.menu = libs.menu.new{title="[PAUSED]"}

  self.menu:add("Continue",function()
    libs.hump.gamestate.switch(states.mission)
  end)

  self.menu:add("Options",function()
    libs.hump.gamestate.switch(states.options)
    previousState = states.pause
  end)

  self.menu:add("End game",function()
    libs.hump.gamestate.switch(states.menu)
  end)

end

function state:update(dt)
  self.menu:update(dt)
end

function state:draw()
  states.mission:draw()
  love.graphics.setColor(0,0,0,100)
  love.graphics.rectangle("fill",0,0,love.graphics:getWidth(),love.graphics:getHeight())
  love.graphics.setColor(255,255,255)
  self.menu:draw()
end

return state
