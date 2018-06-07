local lovernetprofiler = {}

function lovernetprofiler.new(init)
  init = init or {}
  local self = {}

  assert(init.lovernet)
  self._lovernet = init.lovernet
  self.x = init.x or 32
  self.y = init.y or 32
  self.width = init.width or 300
  self.height = init.height or 100


  self.draw = lovernetprofiler.draw
  self.drawGraph = lovernetprofiler.drawGraph
  self.update = lovernetprofiler.update
  self.unload = lovernetprofiler.unload
  self._data = {}

  return self
end

function lovernetprofiler:draw()
  love.graphics.setColor(255,255,255)
  local max = {}
  for typei,type in pairs({"fps","data","serialized"}) do
    max[type] = 0
    for _,v in pairs(self._data) do
      max[type] = math.max(max[type],v[type])
    end
    self:drawGraph(self.x,self.y+(typei-1)*self.height,type,max[type])
  end
end

function lovernetprofiler:drawGraph(x,y,index,max)
  local maxstr = "max "..index..":"..max.."\n"
  love.graphics.print(maxstr,x+self.width,y)
  for i,v in pairs(self._data) do
    love.graphics.line(
      x+i,y+self.height-self.height*v[index]/max,
      x+i,y+self.height)
  end
  love.graphics.rectangle("line",x,y,self.width,self.height)
end

function lovernetprofiler:update(dt)
  local payload = self._lovernet:_encode(self._lovernet._data)
  table.insert(self._data,{
    data=#self._data,
    serialized=#payload,
    fps=love.timer.getFPS(),
  })
  if #self._data > self.width then
    table.remove(self._data,1)
  end

end

function lovernetprofiler:unload()
  self._data = {}
end

return lovernetprofiler
