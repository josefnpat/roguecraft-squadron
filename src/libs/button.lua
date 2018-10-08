local button = {}

function button.new(init)
  init = init or {}
  local self = {}

  self._x = init.x or 32
  self._y = init.y or 32
  self._width = init.width or 256
  self._height = init.height or 40
  self._draw = init.draw or button._default_draw_rcs
  self._text = init.text or "OK"
  self._onClick = init.onClick or button._default_onClick
  self._disabled = init.disabled or false

  self._hover = false
  self._depress = false

  self.update = button.update
  self.mouseInside = button.mouseInside
  self.draw = button.draw
  self.getDisabled = button.getDisabled
  self.setDisabled = button.setDisabled
  self.getX = button.getX
  self.setX = button.setX
  self.getY = button.getY
  self.setY = button.setY
  self.getWidth = button.getWidth
  self.setWidth = button.setWidth
  self.getHeight = button.getHeight
  self.setHeight = button.setHeight
  self.setText = button.setText
  self.setIcon = button.setIcon
  self.setOnClick = button.setOnClick

  return self
end

function button:update(dt)
  local new_hover = self:mouseInside()
  local new_depress = new_hover and love.mouse.isDown(1)
  if new_hover and self._hover and not new_depress and self._depress and not self._disabled then
    self._onClick()
  end
  self._hover = new_hover
  self._depress = new_depress
end

function button:mouseInside()
  local mx,my = love.mouse.getPosition()
  return mx >= self._x and mx < self._x + self._width and
    my >= self._y and my < self._y + self._height
end

function button:draw()
  self._draw(
    type(self._text)=="function" and self._text() or self._text,
    self._icon,
    self._x,self._y,
    self._width,self._height,
    self._hover,self._depress,self._disabled)
end

function button._default_onClick()
  print('button pressed')
end

function button._default_draw_rcs(text,icon,x,y,width,height,hover,depress,disabled)
  local old_color = {love.graphics.getColor()}
  local old_font = love.graphics.getFont()
  local bg,fg
  if disabled then
    bg = {63,63,63,255*7/8}
    fg = {127,127,127,255*7/8}
  else
    bg = hover and {127,127,127,256*7/8} or nil
    fg = depress and {255,255,255} or nil
  end
  tooltipbg(x,y,width,height,bg,fg)
  local offset = (height-fonts.menu:getHeight())/2
  love.graphics.setColor(fg or {0,255,255})
  love.graphics.setFont(fonts.menu)
  if icon then
    local icon_padding = (height - icon:getHeight()) / 2
    love.graphics.draw(icon,x+icon_padding,y+icon_padding)
  end
  if not fg then
    dropshadowf(text,x,y+offset,width,"center")
  else
    love.graphics.printf(text,x,y+offset,width,"center")
  end
  love.graphics.setColor(old_color)
  love.graphics.setFont(old_font)
end

function button._default_draw(text,icon,x,y,width,height,hover,depress,disabled)
  local old_color = {love.graphics.getColor()}
  love.graphics.setColor(hover and {255,255,255} or {191,191,191})
  love.graphics.rectangle("fill",x,y,width,height)
  if depress then
    love.graphics.setColor(255,0,0)
    love.graphics.rectangle("line",x,y,width,height)
  end
  love.graphics.setColor(0,0,0)
  local offset = (height-love.graphics.getFont():getHeight())/2
  love.graphics.printf(text,x,y+offset,width,"center")
  love.graphics.setColor(old_color)
end

function button:getDisabled()
  return self._disabled
end

function button:setDisabled()
  return self._disabled
end

function button:getX()
  return self._x
end

function button:setX(val)
  self._x = val
end

function button:getY()
  return self._y
end

function button:setY(val)
  self._y = val
end

function button:getWidth()
  return self._width
end

function button:setWidth(val)
  self._width = val
end

function button:getHeight()
  return self._height
end

function button:setHeight(val)
  self._height = val
end

function button:setText(val)
  self._text = val
end

function button:setIcon(val)
  self._icon = val
end

function button:setOnClick(val)
  self._onClick = val
end

return button
