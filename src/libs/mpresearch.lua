local mpresearch = {}

function mpresearch.new(init)
  init = init or {}
  local self = {}

  self.lovernet = init.lovernet
  self._onChange = init.onChange or function() end
  self._onChangeScope = init.onChangeScope or function() end

  self.update = mpresearch.update
  self.draw = mpresearch.draw
  self.drawObject = mpresearch.drawObject

  self.active = mpresearch.active
  self.setActive = mpresearch.setActive
  self.getActive = mpresearch.getActive
  self.toggleActive = mpresearch.toggleActive
  self._active = false

  self._preset = init.preset or 1
  self.setPreset = mpresearch.setPreset
  self.getPreset = mpresearch.getPreset

  self.getWidth = mpresearch.getWidth
  self.getHeight = mpresearch.getHeight

  self.mousepressed = mpresearch.mousepressed
  self.mousereleased = mpresearch.mousereleased
  self.buildData = mpresearch.buildData

  self._drawSize = 256+64
  self._drawPadding = 8
  self._buttonWidth = 320
  self._buttonPadding = 8
  self._buttonInternalPadding = 4
  self._objectsSelectWidth = 96

  self._startObject = "command"
  self._currentObject = "command"
  self._dangle = 0

  return self

end

function mpresearch:update(dt)
  self._objects_select:update(dt)
  self._dangle = self._dangle + dt
  for _,button in pairs(self._current_research_buttons) do
    button:update(dt)
  end
end

function mpresearch:draw(user,resources)

  love.graphics.setColor(0,0,0,191)
  love.graphics.rectangle("fill",0,0,
    love.graphics:getWidth(),love.graphics:getHeight())
  love.graphics.setColor(255,255,255)

  local x_offset = (love.graphics.getWidth()-self:getWidth())/2
  local y_offset = (love.graphics.getHeight()-self:getHeight())/2

  tooltipbg(x_offset,y_offset,self:getWidth(),self:getHeight())

  local x = x_offset+self._objects_select:getWidth()
  local y = y_offset
  local w,h = self._drawSize,self:getHeight()
  self:drawObject(self._currentObject,x,y,self._drawSize,self._drawSize)
  local object_type = libs.objectrenderer.getType(self._currentObject)
  love.graphics.setFont(fonts.large)
  dropshadowf(object_type.loc.name,
    x+self._drawPadding,y+self._drawSize,w-self._drawPadding*2,"center")
  love.graphics.setFont(fonts.default)
  dropshadowf(object_type.loc.build,
    x+self._drawPadding,y+self._drawSize+32,w-self._drawPadding*2,"left")

  local button_x_offset = x + self._drawSize
  local button_y_offset = y_offset + 8 + 32

  love.graphics.setFont(fonts.large)
  dropshadowf("Research Points: "..resources:get("research"),
    button_x_offset,y_offset+self._buttonPadding,self._buttonWidth+32,"center")
  love.graphics.setFont(fonts.default)
  if #self._current_research_buttons > 0 then
    for button_index,button in pairs(self._current_research_buttons) do
      button:setX(button_x_offset+32+self._buttonPadding)
      button:setY(button_y_offset + (button:getHeight()+self._buttonInternalPadding)*(button_index-1))
      button:draw()
    end
  else
    dropshadowf("No research available for this object.",
      button_x_offset,y_offset+self._buttonPadding+32,self._buttonWidth,"center")
  end

  -- draw last for tooltips
  self._objects_select:setX(x_offset)
  self._objects_select:setY(y_offset)
  self._objects_select:draw()

  if debug_mode then
    love.graphics.rectangle("line",x_offset,y_offset,
      self:getWidth(),self:getHeight())
      local s = ""
      for i,v in pairs(user.research) do
        s = s .. i .. ": "..tostring(v) .. "\n"
        if type(v) == "table" then
          for j,w in pairs(v) do
            s = s .. "\t" .. j .. ": "..tostring(w) .. "\n"
          end
        end
      end
      love.graphics.print(s,32,128)
  end

end

function mpresearch:drawObject(type,x,y,w,h)

  local demoShip = {
    type = type,
    dx = x+w/2,
    dy = y+h/2,
    render = 1,
    index = 0,
    angle = self._dangle,
    dangle = self._dangle,
  }
  local fakeSelection = {
    isSelected=function() return false end,
    getSelected=function() return {} end,
  }
  libs.objectrenderer.draw(demoShip,{},fakeSelection,0)

end

function mpresearch:active()
  return self._active
end

function mpresearch:setActive(val)
  self._active = val
end

function mpresearch:getActive()
  return self._active
end

function mpresearch:toggleActive()
  self._active = not self._active
end

function mpresearch:setPreset(val)
  self._preset = val
end

function mpresearch:getPreset(val)
  return self._preset
end

function mpresearch:getWidth()
  return self._objects_select:getWidth()+self._drawSize+32+self._buttonWidth
end

function mpresearch:getHeight()
  return 720-32*2 -- self._objects_select:getHeight()
end

function mpresearch:mousepressed(x,y,button)
  if self._objects_select:mouseInside() then
    self._objects_select:runHoverAction()
  end
end

function mpresearch:mousereleased(x,y,button)
end

function mpresearch:buildData(user)

  self._object_types = libs.researchrenderer.getUnlockedObjects(user,self._preset)
  self._objects_select = libs.matrixpanel.new{
    width=self._objectsSelectWidth,
    drawbg=false,
  }
  for _,object_type in pairs(self._object_types) do
    self._objects_select:addAction(
      object_type.icons[1],
      function()
        self._currentObject = object_type.type
        self:buildData(user)
      end,
      function(hover)
        if libs.researchrenderer.isUnlocked(user,object_type) then
          return {0,255,0,hover and 255 or 191}
        else
          return {127,127,127,hover and 255 or 191}
        end
      end,
      function()
        return object_type.loc.name
      end
    )
  end

  self._current_research_buttons = {}

  local current_object_type = libs.objectrenderer.getType(self._currentObject)

  local valid_research = libs.researchrenderer.getValidTypes(current_object_type,user)
  for _,research in pairs(valid_research) do
    local current_level = libs.researchrenderer.getLevel(user,self._currentObject,research.type)
    local button = libs.button.new{
      onClick=function()
        self.lovernet:pushData(libs.net.op.set_research,{
          o=self._currentObject,
          r=research.type,
          v=current_level+1,
        })
        self.lovernet:pushData(libs.net.op.get_research)
      end,
      disabled = current_level == research.max_level
    }
    local cost = ""
    local level = research.max_level == 1 and " " or " (max)"
    if current_level ~= research.max_level then
      cost = " ("..research.cost(current_level)..")"
      level = " "..current_level.."/"..research.max_level
    end
    button:setText(research.loc.name..cost..level)
    button:setWidth(self._buttonWidth-self._buttonPadding*2)
    button:setIcon(research.icon)
    table.insert(self._current_research_buttons,button)
  end

  self._onChange(self._onChangeScope)

end

return mpresearch
