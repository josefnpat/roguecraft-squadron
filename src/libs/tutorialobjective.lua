local tutorialobjective = {}

function tutorialobjective.new(init)
  init = init or {}
  local self = {}

  self.draw = tutorialobjective.draw
  self.update = tutorialobjective.update
  self.updateUI = tutorialobjective.updateUI

  self._padding = init.padding or 8

  self._text = init.text
  self.getText = tutorialobjective.getText
  assert(self._text)

  self._status = init.status
  self.getStatus = tutorialobjective.getStatus
  assert(self._status)

  self._value = init.value
  self.getValue = tutorialobjective.getValue
  assert(self._value)

  self._target = init.target
  self.getTarget = tutorialobjective.getTarget

  self._onComplete = init.onComplete
  self.onComplete = tutorialobjective.onComplete

  self._bar = libs.bar.new{
    width=320,
    padding=0,
    iconPadding=0,
    iconWidth=0,
    barWidth=0,
    drawbg=false,
  }

  self:updateUI()

  return self
end

function tutorialobjective:draw(x,y,w,h)
  self._bar:setX(x+self._padding)
  self._bar:setY(y)
  self._bar:setWidth(w-self._padding*2)
  self._bar:setHeight(h-self._padding)
  self._bar:draw()
end

function tutorialobjective:update(dt)
  self._bar:update(dt)
  self:updateUI()
end

function tutorialobjective:updateUI()
  self._bar:setText(self:getStatus())
  local complete,percent = self:getValue()
  self._bar:setHoverText(complete and "Complete" or ("Incomplete ["..math.floor(percent*100).."%]"))
  self._bar:setBarValue(percent)
end

function tutorialobjective:getText()
  return tostring(self._text)
end

function tutorialobjective:getStatus()
  return type(self._status) == "function" and self._status() or tostring(self._status)
end

function tutorialobjective:getValue()
  local complete,percent
  if type(self._value) == "function" then
    complete,percent = self._value()
  else
    complete = self._value == true
  end
  percent = percent or (complete and 1 or 0)
  return complete,percent
end

function tutorialobjective:getTarget()
  if type(self._target) == "function" then
    return self._target()
  else
    return self._target
  end
end

function tutorialobjective:onComplete()
  if self._onComplete then
    return self._onComplete(self)
  end
end

return tutorialobjective
