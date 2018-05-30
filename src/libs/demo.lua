local demo = {}

demo._timeout = 30
demo._dt = 0
demo._enabled = false

function demo:check()
  if love.filesystem.exists("demo.ogv") then
    self._video = love.graphics.newVideo("demo.ogv")
  end
end

function demo:unload()
  self:stop()
  self._video = nil
end

function demo:update(dt)
  if self._video then
    demo._dt = demo._dt + dt
    if not self._enabled and self._dt > demo._timeout then
      love.mouse.setVisible(false)
      self._enabled = true
      self._video:play()
    end
    if self._enabled == true then
      if not self._video:isPlaying() then
        self._video:play()
      end
    end
  end
end

function demo:draw()
  if self._video then
    if self._enabled then
      love.graphics.draw(self._video,x,y,0,
        love.graphics.getWidth()/self._video:getWidth(),
        love.graphics.getHeight()/self._video:getHeight()
      )
    else
      love.graphics.arc(
        "fill",
        love.graphics.getWidth()-32,
        love.graphics.getHeight()-32,
        16,0,2*math.pi*demo._dt/demo._timeout)
    end
  end
end

function demo:stop()
  if self._video then
    love.mouse.setVisible(true)
    self._enabled = false
    if self._video:isPlaying() then
      self._video:pause()
      self._video:rewind()
    end
    self._dt = 0
  end
end

return demo
