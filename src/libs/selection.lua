local selection = {}

function selection.new(init)
  init = init or {}
  local self = {}

  self._objects = {}
  self._user = -1

  self.start = selection.start
  self._onChange = init.onChange or function() end
  self._onChangeScope = init.onChangeScope or function() end
  self.setOnChange = selection.setOnChange
  self.selectionInProgress = selection.selectionInProgress
  self.isSelection = selection.isSelection
  self.endAdd = selection.endAdd
  self.endSet = selection.endSet
  self.add = selection.add
  self.setSelected = selection.setSelected
  self.setSingleSelected = selection.setSingleSelected
  self.clearSelection = selection.clearSelection
  self.getSelected = selection.getSelected
  self.getUnselected = selection.getUnselected
  self.isSelected = selection.isSelected
  self.update = selection.update
  self.draw = selection.draw
  self.drawPanel = selection.drawPanel
  self.setX = selection.setX
  self.setY = selection.setY
  self.mouseInside = selection.mouseInside
  self.runHoverAction = selection.runHoverAction
  self.getHeight = selection.getHeight
  self.getSelectedIndexes = selection.getSelectedIndexes
  self.setUser = selection.setUser
  self.onChange = selection.onChange
  self._getMinMax = selection._getMinMax
  self._inSelection = selection._inSelection
  self._constraints = selection._constraints

  self.panel = libs.matrixpanel.new{
    width=192,
    padding=1,
  }

  return self
end

function selection:start(x,y)
  self.sx,self.sy = x,y
end

function selection:setOnChange(f)
  self._onChange = f
end

function selection:setOnChangeScope(scope)
  self._onChangeScope = scope
end

function selection:selectionInProgress()
  return self.sx ~= nil and self.sy ~= nil
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
    self:onChange()
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
    self:onChange()
  end
end

function selection:add(object)
  table.insert(self._objects,object)
  self:onChange()
end

function selection:setSelected(objects)
  self._objects = objects
  self:onChange()
end

function selection:setSingleSelected(object)
  self._objects = {object}
  self:onChange()
end

function selection:clearSelection()
  self.sx,self.sy = nil,nil
  self._objects = {}
  self:onChange()
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

function selection:onChange()

  local newobjects = {}
  for _,object in pairs(self._objects) do
    if not libs.net.objectShouldBeRemoved(object) then
      table.insert(newobjects,object)
    end
  end
  self._objects = newobjects

  self.panel:clearActions()
  for _,object in pairs(self:getSelected()) do
    local object_type = libs.objectrenderer.getType(object.type)
    self.panel:addAction(
      object_type.icons[1],
      function(cobject)
        self:setSingleSelected(object)
      end,
      function(hover)
        local alpha = hover and 255 or 191
        if object_type.health then
          local ratio = object.health/object_type.health.max
          if ratio > 0 then
            local color = libs.healthcolor(ratio)
            return {color[1],color[2],color[3],alpha}
          else
            return {0,0,0,alpha}
          end
        else
          return {255,255,255,alpha}
        end
      end,
      function()
        if object_type.health then
          local percent = math.floor(object.health/object_type.health.max*100)
          return object_type.loc.name .. " ["..percent.."%]"
        else
          return object_type.loc.name
        end
      end
    )
  end
  self._onChange(self._onChangeScope)
end

function selection:update(dt)
  self.panel:update(dt)
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

function selection:drawPanel()
  if self.panel:hasActions() then
    self.panel:draw({63,63,63,256*7/8},{255,255,255})
  end
end

function selection:setX(val)
  self.panel:setX(val)
end

function selection:setY(val)
  self.panel:setY(val)
end

function selection:mouseInside(x,y)
  x = x or love.mouse.getX()
  y = y or love.mouse.getY()
  return self.panel:mouseInside(x,y)
end

function selection:runHoverAction()
  self.panel:runHoverAction()
end

function selection:getHeight()
  return self.panel:getHeight()
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
