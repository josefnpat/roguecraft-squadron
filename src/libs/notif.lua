local notif = {}

function notif.new(init)
  init = init or {}
  local self = {}

  self.draw = notif.draw
  self.update = notif.update
  self.add = notif.add

  self._data = {}
  self._dt = 0

  return self
end

function notif:draw()
  if self._current then
    local tfont = love.graphics.getFont()
    local old_color = {love.graphics.getColor()}
    local p = 8
    love.graphics.setColor(0,0,0,127)
    love.graphics.rectangle("fill",
      (love.graphics.getWidth()-tfont:getWidth(self._current.text))/2-p,
      love.graphics.getHeight()*3/4-p,
      tfont:getWidth(self._current.text)+p*2,
      tfont:getHeight()+p*2)
    love.graphics.setColor(old_color)
    dropshadowf(self._current.text,
      0,love.graphics.getHeight()*3/4,love.graphics.getWidth(),"center")
    love.graphics.setColor(old_color)
  end
end

function notif:update(dt)
  if self._current then
    if self._current.sfx then
      if self._current.sfx:isPlaying() then
      else
        self._current = nil
      end
    else
      self._dt = self._dt + dt
      if self._dt > 3 then
        self._dt = 0
        self._current = nil
      end
    end
  else
    if #self._data > 0 then
      self._current = table.remove(self._data,1)
      if self._current.sfx then
        playSFX(self._current.sfx)
      end
    end
  end
end

function notif:add(text,sfx)
  table.insert(self._data,{text=text,sfx=sfx})
end

return notif
