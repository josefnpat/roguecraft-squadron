local mpdisconnect = {}

mpdisconnect.planet = love.graphics.newImage("assets/planets/BubblegumPlanet.png")

function mpdisconnect.new(init)
  init = init or {}
  local self = {}

  self.update = mpdisconnect.update
  self.draw = mpdisconnect.draw
  self.setWin = mpdisconnect.setWin
  self.setLose = mpdisconnect.setLose
  self._start = mpdisconnect._start
  self._ready = mpdisconnect._ready
  self.running = mpdisconnect.running
  self.halt = mpdisconnect.halt

  self._enabled = false
  self._enabled_dt = 0
  self._enabled_max = 5
  self._halt = false

  self.rotate = 0
  self.surrender = libs.button.new{
    text=libs.i18n("mission.mpdisconnect.surrender"),
    onClick=function()
      libs.hump.gamestate.switch(states.menu)
    end,
  }
  self.spectate = libs.button.new{
    text=libs.i18n("mission.mpdisconnect.spectate"),
    onClick=function()
      self._enabled = false
      self._halt = true
    end,
  }

  return self
end

function mpdisconnect:setWin()
  self._gstatus = libs.i18n("mission.mpdisconnect.victory")
  self:_start()
end

function mpdisconnect:setLose()
  self._gstatus = libs.i18n("mission.mpdisconnect.defeat")
  self:_start()
end

function mpdisconnect:_start()
  if self._halt == false then
    self._enabled = true
  end
end

function mpdisconnect:_ready()
  return self._enabled_dt == self._enabled_max
end

function mpdisconnect:running()
  return self._enabled
end

function mpdisconnect:halt()
  self._enabled = false
  self._halt = true
end

function mpdisconnect:update(dt)
  if self._enabled then
    self.rotate = self.rotate + dt
    self._enabled_dt = math.min(self._enabled_dt + dt,self._enabled_max)
    if self:_ready() then
      self.surrender:update(dt)
      self.spectate:update(dt)
    end
  end
end

function mpdisconnect:draw()
  if self._enabled then
    local percent = self._enabled_dt/self._enabled_max
    local old_font = love.graphics.getFont()
    love.graphics.setColor(0,0,0,percent*191)
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
    love.graphics.setColor(255,255,255,percent*255)
    love.graphics.draw(mpdisconnect.planet,
      love.graphics.getWidth()/2,
      love.graphics.getHeight()/2,
      self.rotate/10,1,1,
      mpdisconnect.planet:getWidth()/2,
      mpdisconnect.planet:getHeight()/2)
    love.graphics.setFont(fonts.title)
    love.graphics.printf("["..self._gstatus.."]",
      0,(love.graphics.getHeight()-fonts.title:getHeight())/2,
      love.graphics.getWidth(),"center")
    love.graphics.setFont(old_font)
    if self:_ready() then

      local width = 128

      self.surrender:setX((love.graphics.getWidth()-width)/2-width*5/8)
      self.surrender:setY(love.graphics.getHeight()*5/8)
      self.surrender:setWidth(width)
      self.surrender:draw()

      self.spectate:setX((love.graphics.getWidth()-width)/2+width*5/8)
      self.spectate:setY(love.graphics.getHeight()*5/8)
      self.spectate:setWidth(width)
      self.spectate:draw()

    end
  end
end

return mpdisconnect
