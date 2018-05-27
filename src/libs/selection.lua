local selection = {}

function selection.new(init)
  local self = {}

  self._objects = {}
  self._user = -1

  self.start = selection.start
  self.isSelection = selection.isSelection
  self.endAdd = selection.endAdd
  self.endSet = selection.endSet
  self.setSingleSelected = selection.setSingleSelected
  self.clearSelection = selection.clearSelection
  self.getSelected = selection.getSelected
  self.getUnselected = selection.getUnselected
  self.isSelected = selection.isSelected
  self.draw = selection.draw
  self.getSelectedIndexes = selection.getSelectedIndexes
  self.setUser = selection.setUser
  self._getMinMax = selection._getMinMax
  self._inSelection = selection._inSelection
  self._constraints = selection._constraints

  return self
end

function selection:start(x,y)
  self.sx,self.sy = x,y
end

function selection:isSelection(x,y)
  return self.sx and self.sy and (math.abs(self.sx-x)>16 or math.abs(self.sy-y)>16)
end

function selection:endAdd(x,y,objects)
  if self.sx and self.sy then
    local xmin,ymin,xmax,ymax = self:_getMinMax(self.sx,self.sy,x,y)
    for _,object in pairs(objects) do
      if self:_constraints(object,xmin,ymin,xmax,ymax) and not self:isSelected(object) then
        table.insert(self._objects,object)
      end
    end
    self.sx,self.sy = nil,nil
  end
end

function selection:endSet(x,y,objects)
  if self.sx and self.sy then
    self._objects = {}
    local xmin,ymin,xmax,ymax = self:_getMinMax(self.sx,self.sy,x,y)
    for _,object in pairs(objects) do
      if self:_constraints(object,xmin,ymin,xmax,ymax) then
        table.insert(self._objects,object)
      end
    end
    self.sx,self.sy = nil,nil
  end
end

function selection:setSingleSelected(object)
  self._objects = {object}
end

function selection:clearSelection()
  self.sx,self.sy = nil,nil
  self._objects = {}
end

function selection:getSelected()
  return self._objects
end

function selection:getUnselected(objects)
  local unsel = {}
  for _,object in pairs(objects) do
    if not self:isSelected(object) then
      table.insert(unsel,object)
    end
  end
  return unsel
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

function selection:getSelectedIndexes()
  local indexes = {}
  for _,object in pairs(self._objects) do
    table.insert(indexes,object.index)
  end
  return indexes
end

function selection:setUser(user)
  self._user = user
end

function selection:draw(camera)
  if self.sx and self.sy then
    local mx,my = love.mouse.getPosition()
    love.graphics.rectangle("line",
      self.sx,
      self.sy,
      mx-self.sx-love.graphics.getWidth()/2+camera.x,
      my-self.sy-love.graphics.getHeight()/2+camera.y)
  end
end

function selection:_getMinMax(x,y,x2,y2)
  return math.min(x,x2),math.min(y,y2),math.max(x,x2),math.max(y,y2)
end

function selection:_inSelection(object,xmin,ymin,xmax,ymax)
  return object.dx >= xmin and object.dx <= xmax and
    object.dy >= ymin and object.dy <= ymax
end

function selection:_constraints(object,xmin,ymin,xmax,ymax)
  return self:_inSelection(object,xmin,ymin,xmax,ymax) and self._user == object.user
end

return selection
