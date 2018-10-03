local slider = {}

function slider.new(init)
  init = init or {}
  local self = {}

  self.update = slider.update
  self.draw = slider.draw
  self.mouseInside = slider.mouseInside
  self._onChange = init.onChange or slider._onChange
  self.setOnChange = slider.setOnChange

  self._value = init.value or 0.5
  self.setValue = slider.setValue
  self.getValue = slider.getValue

  self._text = init.text or slider.defaultText
  self.setText = slider.setText
  self.getText = slider.getText

  self._barPadding = 4
  self._barColor = init.color or {246,197,42}
  self._textColor = init.textColor or {0,0,0}
  self._textInverseColor = init.textInverseColor or {255,255,255}

  self._x = init.x or 32
  self.setX = slider.setX
  self.getX = slider.getX
  self._y = init.y or 32
  self.setY = slider.setY
  self.getY = slider.getY
  self._width = init.width or 256
  self.setWidth = slider.setWidth
  self.getWidth = slider.getWidth
  self._height = init.height or 48
  self.setHeight = slider.setHeight
  self.getHeight = slider.getHeight

  return self
end

function slider:defaultText()
  return "value: " .. math.floor(self._value*100)/100
end

function slider:update(dt)
  if love.mouse.isDown(1) and self:mouseInside() then
    local mx = love.mouse.getX()
    self._value = (mx - self._x)/self._width
    if self._onChange then
      self._onChange(self._value)
    end
  end
end

function slider:setOnChange(val)
  assert(type(val)=="function")
  self._onChange = val
end

function slider:draw()
  local old_color = {love.graphics.getColor()}
  tooltipbg(self._x,self._y,self._width,self._height)
  local tvoff = (self._height-love.graphics.getFont():getHeight())/2
  local text = type(self._text)=="function" and self._text(self) or tostring(self._text)
  love.graphics.setColor(self._textInverseColor)
  love.graphics.printf(text,self._x,self._y+tvoff,self._width,"center")
  love.graphics.setColor(self._barColor)
  local barwidth = (self._width-self._barPadding*2)*self._value

  love.graphics.rectangle("fill",
    self._x+self._barPadding,
    self._y+self._barPadding,
    barwidth,
    self._height-self._barPadding*2)

  love.graphics.setScissor(self._x,self._y,barwidth,self._height)
  love.graphics.setColor(self._textColor)
  love.graphics.printf(text,self._x,self._y+tvoff,self._width,"center")
  love.graphics.setScissor()
  love.graphics.setColor(old_color)
  if debug_mode then
    debugrect(self._x,self._y,self._width,self._height)
  end
end

function slider:mouseInside()
  local mx,my = love.mouse.getPosition()
  return mx >= self._x and mx < self._x + self._width and
    my >= self._y and my < self._y + self._height
end

function slider:setValue(val)
  self._value = val
end

function slider:getValue()
  return self._value
end

function slider:setX(val)
  self._x = val
end

function slider:getX()
  return self._x
end

function slider:setY(val)
  self._y = val
end

function slider:getY()
  return self._y
end

function slider:setWidth(val)
  self._width = val
end

function slider:getWidth()
  return self._width
end

function slider:setHeight(val)
  self._height = val
end

function slider:getHeight()
  return self._height
end

return slider
