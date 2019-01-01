local system = {}

function system:draw()
  if self._text then
    local old_font = love.graphics.getFont()
    if fonts then
      love.graphics.setFont(fonts.small)
    end
    love.graphics.print(self._text)
    love.graphics.setFont(old_font)
  end
end

function system:set(text,duration)
  self._text = text
  self._duration = duration
end

function system:update(dt)
  if self._duration then
    self._duration = self._duration - dt
    if self._duration <= 0 then
      self._duration = nil
      self._text = nil
    end
  end
end

return system
