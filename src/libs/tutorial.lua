local tutorial = {}

function tutorial.new()
  local self = {}

  self.draw = tutorial.draw
  self.update = tutorial.update
  self.add = tutorial.add

  self._data = {}
  self._current = 1

  return self
end

function tutorial:draw()
  local current = self._data[self._current]
  if current then
    local tx,ty = 256,128+64
    local f = love.graphics.getFont()
    local w,h = f:getWidth(current.text),f:getHeight()
    love.graphics.rectangle("line",tx,ty,w,h)
    love.graphics.print(current.text,tx,ty)
    local x,y = current:target()
    love.graphics.line(tx+w,ty+h,x,y)
  end
end

function tutorial:update(dt)
  local current = self._data[self._current]
  if current then
    if current:wait() == false then
      self._current = self._current + 1
    end
  end
end

function tutorial:add(text,target,wait)
  table.insert(self._data,{
    text=text,
    target=target,
    wait=wait,
  })
end

return tutorial
