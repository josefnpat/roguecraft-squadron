local countdown = {}

function countdown.new(init)
  init = init or {}
  local self = {}

  self.draw = countdown.draw
  self.update = countdown.update
  self.setActive = countdown.setActive
  self.getActive = countdown.getActive

  self._padding = init.padding or 12
  self._textPadding = init.textPadding or 8
  self._subtextPadding = init.subtextPadding or 8

  self._x = init.x or 100
  self.setX = countdown.setX
  self.getX = countdown.getX

  self._y = init.y or 100
  self.setY = countdown.setY
  self.getY = countdown.getY

  self.getWidth = countdown.getWidth
  self.getHeight = countdown.getHeight

  self._text = init.text or "Text"
  self._textFont = fonts.default

  self._subtext = init.subtext or "Subtext"
  self._subtextFont = fonts.small

  self._bar = libs.bar.new{
    width=320,
    padding=0,
    iconPadding=0,
    iconWidth=0,
    barWidth=0,
    drawbg=false,
  }

  return self
end

function countdown:draw(time)
  if debug_hide_hud then return end
  if not self:getActive(time) then return end
  tooltipbg(self._x,self._y,self:getWidth(),self:getHeight())
  love.graphics.setFont(self._textFont)
  local textHeight = self._textFont:getHeight()
  love.graphics.printf(self._text,
    self._x+self._padding,
    self._y+self._padding,
    self:getWidth()-self._padding*2,"center")
  love.graphics.setFont(self._subtextFont)
  local subtextHeight = self._subtextFont:getHeight()
  love.graphics.printf(self._subtext,
    self._x+self._padding,
    self._y+self._padding+textHeight,
    self:getWidth()-self._padding*2,"center")
  love.graphics.setFont(fonts.default)
  self._bar:setY(self._y+self._padding+textHeight+self._subtextPadding+subtextHeight)
  self._bar:setX(self._x+self._padding)
  local timeRemaining = math.max(0,self._duration - (time - self._start))
  local timeTotal = self._duration
  local timePercent = timeRemaining/timeTotal
  local text = "Time Remaining: "..seconds_to_clock(timeRemaining)
  self._bar:setText(text)
  self._bar:setHoverText(math.floor(timeRemaining).."/"..timeTotal.." ["..math.floor(timePercent*100).."%]")
  self._bar:setBarValue(timePercent)
  self._bar:draw()
end

function countdown:update(dt)
  -- if not self._active then return end
  self._bar:update(dt)
end

function countdown:setActive(start,duration)
  if start and duration then
    self._start = start
    self._duration = duration
  else
    self._start,self._duration = nil,nil
  end
end

function countdown:getActive(time)
  return self._start and self._duration --and self._start + self._duration < time
end

function countdown:getX()
  return self._x
end

function countdown:setX(val)
  self._x = val
end

function countdown:getY()
  return self._y
end

function countdown:setY(val)
  self._y = val
end

function countdown:getWidth()
  return self._bar:getWidth()+self._padding*2
end

function countdown:getHeight()
  return self._textFont:getHeight()+
    self._subtextFont:getHeight()+
    self._bar:getHeight()+
    self._padding*2+
    self._textPadding+
    self._subtextPadding
end

return countdown
