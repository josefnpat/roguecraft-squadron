local drawable = {}

drawable.img = {
  hint = love.graphics.newImage("assets/hud/hint.png"),
}

function drawable.new(init)
  init = init or {}
  local self = {}

  self._x = init.x or 32
  self.getX = drawable.getX
  self.setX = drawable.setX

  self._y = init.y or 32
  self.getY = drawable.getY
  self.setY = drawable.setY

  self._padding = init.padding or 12
  self.getPadding = drawable.getPadding
  self.setPadding = drawable.setPadding

  self._width = init.width or 128
  self.getWidth = drawable.getWidth
  self.setWidth = drawable.setWidth

  self._height = init.height or 64
  self.getHeight = drawable.getHeight
  self.setHeight = drawable.setHeight

  self._hintTime = 0
  self.updateHint = drawable.updateHint
  self.drawHint = drawable.drawHint

  return self
end

function drawable:getX()
  return self._x
end

function drawable:setX(x)
  self._x = x
end

function drawable:getY()
  return self._y
end

function drawable:setY(y)
  self._y = y
end

function drawable:getPadding()
  return self._padding
end

function drawable:setPadding(padding)
  self._padding = padding
end

function drawable:getWidth()
  return self._width
end

function drawable:setWidth(width)
  self._width = width
end

function drawable:getHeight()
  return self._height
end

function drawable:setHeight(height)
  self._height = height
end

function drawable:updateHint(dt)
  self._hintTime = self._hintTime + dt*4
end

function drawable:drawHint()
  love.graphics.setColor(math.sin(self._hintTime*4)*255,255,0)
  love.graphics.draw(drawable.img.hint,
    self:getX()+self:getWidth()+math.sin(self._hintTime)*8,
    self:getY()+(self:getHeight()-drawable.img.hint:getHeight())/2)
end

return drawable
