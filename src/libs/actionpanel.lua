local actionpanel = {}

function actionpanel.new(init)
  init = init or {}
  local self = {}

  self._x = init.x or 32
  self._y = init.y or 32
  self.update = actionpanel.update
  self.draw = actionpanel.draw
  self.process = actionpanel.process
  self.mouseInside = actionpanel.mouseInside
  self.runHoverAction = actionpanel.runHoverAction
  self.makeCostString = actionpanel.makeCostString
  self.getSelectedActions = actionpanel.getSelectedActions
  self.getHeight = actionpanel.getHeight
  self.setX = actionpanel.setX
  self.setY = actionpanel.setY

  self.panel = libs.matrixpanel.new{
    x=self._x,
    y=self._y,
    width=192,
    padding=1,
  }

  return self
end

function actionpanel:update(dt)
  self.panel:update(dt)
end

function actionpanel:draw()
  if self.panel:hasActions() then
    self.panel:draw()
  end
end

function actionpanel:setX(val)
  self._x = val
  self.panel:setX(val)
end

function actionpanel:setY(val)
  self._y = val
  self.panel:setY(val)
end

function actionpanel:makeCostString(costs)
  if costs == nil then return "Free" end
  local s = {}
  for resource_type,cost in pairs(costs) do
    table.insert(s,resource_type..": "..cost)
  end
  return table.concat(s," + ")
end

function actionpanel:getSelectedActions(selected,user)
  local selection_types = {}
  for _,object in pairs(selected) do
    local object_type = libs.objectrenderer.getType(object.type)
    if object.user == user.id and object_type.actions then
      for _,action in pairs(object_type.actions) do
        selection_types[action] = (selection_types[action] or 0) + 1
      end
    end
  end
  local valid = {}
  for action,count in pairs(selection_types) do
    if count == #selected then
      valid[action] = true
    end
  end
  return valid
end

function actionpanel:process(selection,user,resources,buildqueue)

  local selected = selection:getSelected()
  self.panel:clearActions()

  local selected_actions = self:getSelectedActions(selected,user)

  -- build commands
  for _,object_type in pairs(libs.objectrenderer.getTypes()) do

    local action = "build_"..object_type.type
    local valid = selected_actions[action]
    if valid then
      self.panel:addAction(
        object_type.icons[1],
        function()
          for _,selected_object in pairs(selection:getSelected()) do
            buildqueue:add(selected_object,object_type,action)
          end
        end,
        function(hover)
          local alpha = hover and 255 or 191
          return resources:canAfford(object_type) and {0,255,255,alpha} or {255,0,0,alpha}
        end,
        function()
          local build_name = object_type.loc.name
          local build_cost = self:makeCostString(object_type.cost)
          local info = object_type.loc.info
          return libs.i18n(
            'mission.build_status.ready',
            {build_name=build_name,build_cost=build_cost}
          ) .. "\n" .. info
        end,
        object_type.cost and object_type.cost.material or 0
      )
      self.panel:sort()
    end

  end

end

function actionpanel:mouseInside(x,y)
  x = x or love.mouse.getX()
  y = y or love.mouse.getY()
  return self.panel:mouseInside(x,y)
end

function actionpanel:runHoverAction()
  self.panel:runHoverAction()
end

function actionpanel:getHeight()
  return self.panel:hasActions() and self.panel:getHeight() or 0
end

return actionpanel
