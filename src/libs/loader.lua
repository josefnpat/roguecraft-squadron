local loader = {}

loader.image = love.graphics.newImage("assets/loading.png")

function loader.new(init)
  init = init or {}
  local self = {}

  self._data = {}
  self.add = loader.add
  self.draw = loader.draw
  self.update = loader.update

  self._onDone = init.onDone or function() end
  self.setOnDone = loader.setOnDone

  self._frame_t = 1/60
  self._frame_dt = 0
  self._current = 1

  self._str = ""

  return self
end

function loader:add(str,f)
  table.insert(self._data,{
    f=f,
    str=str,
  })
end

function loader:draw()
  local x = love.graphics.getWidth()/4
  local y = love.graphics.getHeight()*7/8
  local w = love.graphics.getWidth()/2
  local h = 32
  local p = 4
  local percent = self._current/#self._data

  love.graphics.draw(loader.image,
    (love.graphics.getWidth()-loader.image:getWidth())/2,
    (love.graphics.getHeight()-loader.image:getHeight())/2
  )

  love.graphics.printf("Loading " .. self._data[self._current].str,x,y-32,love.graphics.getWidth()/2,"center")
  love.graphics.rectangle("line",x,y,w,h)
  love.graphics.rectangle("fill",x+p,y+p,(w-p*2)*percent,h-p*2)
end

function loader:update(dt)
  if self._data[self._current] then
    local time = love.timer.getTime()
    self._data[self._current].f()
    local delta = love.timer.getTime()-time
    local ms = math.floor(delta*1000)
    --print(math.floor(delta*1000).." ms",self._data[self._current].str)
    if self._data[self._current + 1] then
      self._current = self._current + 1
    else
      loader.image = nil
      self._onDone()
    end
  end
end

function loader:setOnDone(f)
  self._onDone = f
end

return loader
