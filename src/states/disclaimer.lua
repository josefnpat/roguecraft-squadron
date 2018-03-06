local disclaimer = {}

function disclaimer:init()
  self.pre = libs.i18n('disclaimer.pre')
end

function disclaimer:enter()
  local index = 'disclaimer.'..math.random(1,13)
  self.post = libs.i18n(index)
end

function disclaimer:draw()
  love.graphics.setFont(fonts.menu)
  local px = love.graphics.getWidth()/4
  local py = love.graphics.getHeight()/4
  love.graphics.printf(
    self.pre .. " " .. self.post,
    px,py,px*2,"center")
  love.graphics.setFont(fonts.default)
end

function disclaimer:mousepressed()
  self:getouttahere()
end

function disclaimer:keypressed(key)
  if key == "f5" then
    self:enter()
  else
    self:getouttahere()
  end
end

function disclaimer:getouttahere()
  --TODO: skip tree if no points
  libs.hump.gamestate.switch(states.tree)
end

return disclaimer
