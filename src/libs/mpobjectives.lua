local mpobjectives = {}

function mpobjectives.new(init)
  init = init or {}
  local self = libs.mpwindow.new()

  self.getWidth = mpobjectives.getWidth -- override
  self.getHeight = mpobjectives.getHeight -- override
  self.draw = mpobjectives.draw
  self.update = mpobjectives.update

  self._dt = 0
  self._text = "Destroy all enemy ships."

  self:setWindowTitle("Objectives")

  return self
end

function mpobjectives:getWidth()
  return 320
end

function mpobjectives:getHeight()
  return 240
end

function mpobjectives:draw()

  if self:isActive() then

    local window,content = self:windowdraw()

    libs.reflowprint{
      progress=self._dt,
      print=dropshadow,
      text=self._text,
      x=content.x,
      y=content.y,
      w=content.width,
      a="center",
    }

    local padding = self._padding

  end

end

function mpobjectives:update(dt)
  if self:isActive() then
    self:windowupdate(dt)
    self._dt = math.min(1,self._dt + dt)
  else
    self._dt = 0
  end
end

return mpobjectives
