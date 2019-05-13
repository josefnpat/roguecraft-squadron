local barlib = {}

barlib.img = {
  corner = love.graphics.newImage("assets/hud/bar_corner.png"),
  horizontal = love.graphics.newImage("assets/hud/bar_horizontal.png"),
}

function barlib.new(init)
  init = init or {}
  local self = libs.drawable.new(init)
  self._drawbg = init.drawbg == nil and true or init.drawbg
  self._text = init.text or "Bar Lib"
  self._hoverText = init.hoverText or "Bar Lib Hover"
  -- self._x = init.x or 32
  -- self._y = init.y or 32
  self._padding = init.padding or 12
  self._width = init.width or 192
  self._height = init.height or barlib.img.corner:getHeight()+self._padding*2
  self._color = init.color or {0,255,255}
  self._barColor = init.color or {246,197,42}
  self._barColorFull = init.colorFull or {0,255,255}
  self._textColorFull = init.textColorFull or {0,0,0}
  self._textColor = init.textColor or {0,0,0}
  self._textInverseColor = init.textInverseColor or {255,255,255}
  self._icon = init.icon
  self._iconPadding = init.iconPadding or 8
  self._iconWidth = init.iconWidth or 32
  self._barValue = init.barValue or 0.5
  self._barValueDrawn = init._barValueDrawn or self._barValue
  self._barHeight = init.barHeight or 2
  self._barWidth = init.barWidth or 2
  self._barEnable = init.barEnable or true
  self._alpha = init.alpha or 255
  self._hover = false
  self.draw = barlib.draw
  self.update = barlib.update
  self.setText = barlib.setText
  self.setHoverText = barlib.setHoverText
  self.setColor = barlib.setColor
  self.setBarColor = barlib.setBarColor
  self.setTextColor = barlib.setTextColor
  self.setTextInverseColor = barlib.setTextInverseColor
  self.setIcon = barlib.setIcon
  self.setIconPadding = barlib.setIconPadding
  self.setBarValue = barlib.setBarValue
  self.setBarHeight = barlib.setBarHeight
  self.setBarWid7th = barlib.setBarWidth
  self.setBarEnable = barlib.setBarEnable
  self.getBarEnable = barlib.getBarEnable
  self.setAlpha = barlib.setAlpha
  self.mouseInside = barlib.mouseInside

  return self
end

function barlib:draw()
  if debug_hide_hud then return end
  if not self._barEnable then return end
  local old_color = {love.graphics.getColor()}
  if self._drawbg then
    tooltipbg(self._x,self._y,self._width,self._height)
  end
  if debug_mode then
    love.graphics.rectangle("line",self._x,self._y,self._width,self._height)
  end
  if self._icon then
    love.graphics.setColor(255,255,255,self._alpha)
    love.graphics.draw(self._icon,
      self._x+self._width-self._icon:getWidth()-self._padding,
      self._y+self._height-self._icon:getHeight()-self._padding
    )
  end
  local iconw = self._icon and self._icon:getWidth() or self._iconWidth
  local iconh = self._icon and self._icon:getWidth() or self._iconWidth
  love.graphics.setColor(
    self._color[1],
    self._color[2],
    self._color[3],
    self._color[4] or self._alpha)
  love.graphics.draw(barlib.img.corner,
    self._x+self._width-iconw-barlib.img.corner:getWidth()-self._padding-self._iconPadding,
    self._y+self._height-barlib.img.corner:getHeight()-self._padding)
  love.graphics.draw(barlib.img.horizontal,
    self._x+self._padding,
    self._y+self._height-self._padding-self._barHeight,
    0,
    (self._width-iconw-self._padding*2-self._iconPadding)/barlib.img.horizontal:getWidth(),self._barHeight)
  local tx = self._x+self._padding
  local ty = self._y+self._padding
  local tw = self._width-self._padding*2-self._iconWidth-self._barWidth-self._iconPadding
  local th = self._height-self._padding*2
  local thoff = (th-love.graphics.getFont():getHeight())/2
  local _text = type(self._text)=="function" and self._text() or tostring(self._text)
  local _hoverText = type(self._hoverText)=="function" and self._hoverText() or tostring(self._hoverText)
  local ttext = self._hover and _hoverText or _text
  local bx,by = tx,ty
  local bw = (tw)*self._barValueDrawn
  local bh = self._height-self._padding*2-self._barHeight

  love.graphics.setColor(
    self._textInverseColor[1],
    self._textInverseColor[2],
    self._textInverseColor[3],
    self._textInverseColor[4] or self._alpha)
  love.graphics.printf(ttext,tx,ty+thoff,tw,"center")
  if self._barValueDrawn >= 1 then
    love.graphics.setColor(
      self._barColorFull[1],
      self._barColorFull[2],
      self._barColorFull[3],
      self._barColorFull[4] or self._alpha)
  else
    love.graphics.setColor(
      self._barColor[1],
      self._barColor[2],
      self._barColor[3],
      self._barColor[4] or self._alpha)
  end
  love.graphics.rectangle("fill",bx,by,bw,bh)
  love.graphics.setScissor(bx,by,bw,bh)
  if self._barValueDrawn >= 1 then
    love.graphics.setColor(
      self._textColorFull[1],
      self._textColorFull[2],
      self._textColorFull[3],
      self._textColorFull[4] or self._alpha)
  else
    love.graphics.setColor(
      self._textColor[1],
      self._textColor[2],
      self._textColor[3],
      self._textColor[4] or self._alpha)
  end
  love.graphics.printf(ttext,tx,ty+thoff,tw,"center")
  love.graphics.setScissor()
  love.graphics.setColor(old_color)
  if debug_mode then
    debugrect(self._x,self._y,self._width,self._height)
    self:drawHint()
  end
end

function barlib:update(dt)

  self:updateHint(dt)

  if self._barValueDrawn < self._barValue then
    if self._barValueDrawn + dt > self._barValue then
      self._barValueDrawn = self._barValue
    else
      self._barValueDrawn = self._barValueDrawn + dt
    end
  elseif self._barValueDrawn > self._barValue then
    if self._barValueDrawn - dt < self._barValue then
      self._barValueDrawn = self._barValue
    else
      self._barValueDrawn = self._barValueDrawn - dt
    end
  end

  local mx,my = love.mouse.getPosition()
  self._hover = mx >= self._x and my >= self._y and
    mx <= self._x + self._width and my <= self._y + self._height
end

function barlib:setText(text)
  self._text = text
end

function barlib:setHoverText(hoverText)
  self._hoverText = hoverText
end

function barlib:setColor(color)
  self._color = color
end

function barlib:setBarColor(barColor)
  self._barColor = barColor
end

function barlib:setTextColor(textColor)
  self._textColor = textColor
end

function barlib:setIcon(icon)
  self._icon = icon
end

function barlib:setIconPadding(iconPadding)
  self._iconPadding = iconPadding
end

function barlib:setBarValue(barValue)
  self._barValue = barValue
end

function barlib:setBarHeight(barHeight)
  self._barHeight = barHeight
end

function barlib:setBarWidth(barWidth)
  self._barWidth = barWidth
end

function barlib:setBarEnable(barEnable)
  self._barEnable = barEnable
end

function barlib:getBarEnable(barEnable)
  return self._barEnable
end

function barlib:setAlpha(val)
  self._alpha = val
end

function barlib:mouseInside()
  return self._hover
end

return barlib
