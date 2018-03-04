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
    local padding = 32
    local tfont = love.graphics.getFont()
    local old_color = {love.graphics.getColor()}
    local w = tfont:getWidth(self._current.text)+padding
    local h = tfont:getHeight()+padding
    tooltipbg(
      love.graphics.getWidth()/2-w/2,
      love.graphics.getHeight()*3/4-h/2,
      w,h)
    dropshadowf(self._current.text,
      0,love.graphics.getHeight()*3/4-tfont:getHeight()/2,love.graphics.getWidth(),"center")
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
