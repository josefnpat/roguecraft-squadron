local stepper = {}

function stepper.new(init)
  init = init or {}
  local self = {}

  self._x = init.x or 32
  self._y = init.y or 32
  self._width = init.width or 256
  self._height = init.height or 40
  self.update = stepper.update
  self.mouseInside = stepper.mouseInside
  self.draw = stepper.draw
  self.getDisabled = stepper.getDisabled
  self.setDisabled = stepper.setDisabled
  self.getX = stepper.getX
  self.setX = stepper.setX
  self.getY = stepper.getY
  self.setY = stepper.setY
  self.getWidth = stepper.getWidth
  self.setWidth = stepper.setWidth
  self.getHeight = stepper.getHeight
  self.setHeight = stepper.setHeight
  self.setText = stepper.setText
  self.setIcon = stepper.setIcon
  self.setOnClick = stepper.setOnClick
  self.setFont = stepper.setFont
  self._align = stepper._align

  self._down = libs.button.new{
    text="-",
    width=32,
    dir=-1,
    onClick=init.onClick,
    font=init.font,
  }
  self._info = libs.button.new{
    init.text or "OK",
    dir=1,
    onClick=init.onClick,
    font=init.font,
  }
  self._up = libs.button.new{
    text="+",
    width=32,
    dir=1,
    onClick=init.onClick,
    font=init.font,
  }

  self:_align()

  return self
end

function stepper:update(dt)
  self._down:update(dt)
  self._info:update(dt)
  self._up:update(dt)
end

function stepper:mouseInside()
  return self._down:mouseInside() or
    self._info:mouseInside() or
    self._up:mouseInside()
end

function stepper:draw()
  self._down:draw()
  self._info:draw()
  self._up:draw()
end

function stepper:getDisabled()
  return self._info:getDisabled()
end

function stepper:setDisabled(val)
  self._down:setDisabled(val)
  self._info:setDisabled(val)
  self._up:setDisabled(val)
end

function stepper:getX()
  return self._down:getX()
end

function stepper:setX(val)
  self._down:setX(val)
  self._info:setX(val+self._down:getWidth())
  self._up:setX(val+self._info:getWidth()+self._down:getWidth())
end

function stepper:getY()
  return self._info:getY()
end

function stepper:setY(val)
  self._down:setY(val)
  self._info:setY(val)
  self._up:setY(val)
end

function stepper:getWidth()
  return self._width
end

function stepper:setWidth(val)
  self._info:setWidth(val-self._down:getWidth()-self._up:getWidth())
  self:_align()
end

function stepper:getHeight()
  return self._info:getHeight()
end

function stepper:setHeight(val)
  self._down:setHeight(val)
  self._info:setHeight(val)
  self._up:setHeight(val)
end

function stepper:setText(val)
  self._info:setText(val)
end

function stepper:setIcon(val)
  self._info:setIcon(val)
end

function stepper:setOnClick(val)
  self._down:setOnClick(val)
  self._up:setOnClick(val)
end

function stepper:setFont(val)
  self._down:setFont(val)
  self._info:setFont(val)
  self._up:setFont(val)
end

function stepper:_align()
  self:setX(self:getX())
end

return stepper
