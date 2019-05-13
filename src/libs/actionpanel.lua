local actionpanel = {}

function actionpanel.new(init)
  init = init or {}
  local self = libs.drawable.new(init)

  self._x = init.x or 32
  self._y = init.y or 32
  self.update = actionpanel.update
  self.draw = actionpanel.draw
  self.process = actionpanel.process
  self.mouseInside = actionpanel.mouseInside
  self.runHoverAction = actionpanel.runHoverAction
  self.runAction = actionpanel.runAction
  self.makeCostString = actionpanel.makeCostString
  self.getSelectedActions = actionpanel.getSelectedActions
  self.getHeight = actionpanel.getHeight
  self.setX = actionpanel.setX
  self.setY = actionpanel.setY
  self.showPanel = actionpanel.showPanel
  self._width = 192
  self.panel = libs.matrixpanel.new{
    x=self._x,
    y=self._y,
    width=self._width,
    padding=1,
  }

  return self
end

function actionpanel:update(dt)
  self:updateHint(dt)
  self.panel:update(dt)
end

function actionpanel:draw()
  self.panel:draw()
end

function actionpanel:setX(val)
  self._x = val
  self.panel:setX(val)
end

function actionpanel:setY(val)
  self._y = val
  self.panel:setY(val)
end

function actionpanel:showPanel()
  return self.panel:hasActions()
end

-- no longer used, I think - check out objectrenderer's tooltip system
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

function actionpanel:process(selection,user,points,resources,buildqueue)

  local selected = selection:getSelected()
  self.panel:clearActions()

  local selected_actions = self:getSelectedActions(selected,user)

  -- build commands
  for _,object_type in pairs(libs.objectrenderer.getTypes()) do

    local action = "build_"..object_type.type
    local valid = selected_actions[action] and libs.researchrenderer.isUnlocked(user,object_type)
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
        function(x,y)
          return function() -- override tooltip
            libs.objectrenderer.tooltipBuild(
              object_type,
              x,
              y,
              points,
              resources,
              {
                use_build_header=true,
              }
            )
          end
        end,
        object_type.cost and object_type.cost.material or 0
      )
      self.panel:sort()
      self.panel:applyIconShortcutKeyTable(settings:read('action_keys'))
    end

  end

end

function actionpanel:mouseInside(x,y)
  x = x or love.mouse.getX()
  y = y or love.mouse.getY()
  if self:showPanel() then
    return self.panel:mouseInside(x,y)
  end
  return false
end

function actionpanel:runHoverAction()
  self.panel:runHoverAction()
end

function actionpanel:runAction(index)
  self.panel:runAction(index)
end

function actionpanel:getHeight()
  return self.panel:hasActions() and self.panel:getHeight() or 0
end

return actionpanel
