local selection = {}

function selection.new(init)
  local self = {}

  self._objects = {}

  self.start = selection.start
  self.endAdd = selection.endAdd
  self.endSet = selection.endSet
  self.getSelected = selection.getSelected
  self.isSelected = selection.isSelected
  self.draw = selection.draw
  self._getMinMax = selection._getMinMax
  self._inSelection = selection._inSelection

  return self
end

function selection:start(x,y)
  self.sx,self.sy = x,y
end

function selection:endAdd(x,y,objects)
  local xmin,ymin,xmax,ymax = self:_getMinMax(self.sx,self.sy,x,y)
  for _,object in pairs(objects) do
    if self:_inSelection(object,xmin,ymin,xmax,ymax) and not self:isSelected(object) then
      table.insert(self._objects)
    end
  end
  self.sx,self.sy = nil,nil
end

function selection:endSet(x,y,objects)
  self._objects = {}
  local xmin,ymin,xmax,ymax = self:_getMinMax(self.sx,self.sy,x,y)
  for _,object in pairs(objects) do
    if self:_inSelection(object,xmin,ymin,xmax,ymax) then
      table.insert(self._objects,object)
    end
  end
  self.sx,self.sy = nil,nil
end

function selection:getSelected()
  return self._objects
end

function selection:isSelected(objectTest)
  -- todo: add cache
  for _,object in pairs(self._objects) do
    if object == objectTest then
      return true
    end
  end
  return false
end

function selection:draw()
  if self.sx and self.sy then
    local mx,my = love.mouse.getPosition()
    love.graphics.rectangle("line",self.sx,self.sy,mx-self.sx,my-self.sy)
  end
end

function selection:_getMinMax(x,y,x2,y2)
  return math.min(x,x2),math.min(y,y2),math.max(x,x2),math.max(y,y2)
end

function selection:_inSelection(object,xmin,ymin,xmax,ymax)
  return object.x >= xmin and object.x <= xmax and
    object.y >= ymin and object.y <= ymax
end

return selection
