local mpresearch = {}

function mpresearch.new(init)
  init = init or {}
  local self = libs.mpwindow.new()

  self.lovernet = init.lovernet
  self._onChange = init.onChange or function() end
  self._onChangeScope = init.onChangeScope or function() end

  self.update = mpresearch.update

  self.getDescText = mpresearch.getDescText
  self.getDescTextWidth = mpresearch.getDescTextWidth
  self.getDescTextHeight = mpresearch.getDescTextHeight

  self.draw = mpresearch.draw
  self.drawObject = mpresearch.drawObject

  self._players = init.players
  self.setPlayers = mpresearch.setPlayers
  self.getPlayers = mpresearch.getPlayers

  self.getWidth = mpresearch.getWidth
  self.getHeight = mpresearch.getHeight
  self.getSubContentWidth = mpresearch.getSubContentWidth
  self.getSubContentHeight = mpresearch.getSubContentHeight

  self.mousepressed = mpresearch.mousepressed
  self.mousereleased = mpresearch.mousereleased
  self.canAffordAnything = mpresearch.canAffordAnything
  self.canUnlockAnything = mpresearch.canUnlockAnything
  self.setGenFirst = mpresearch.setGenFirst
  self.buildData = mpresearch.buildData
  self.getObjectSelectAction = mpresearch.getObjectSelectAction

  self._drawSize = 256+self._padding*2
  self._objectsSelectWidth = 32*2
  self._buttonWidth = 256

  self._desc_font = fonts.default

  self._startObject = "command"
  self._currentObject = "command"
  self._dangle = 0

  self._objects_select = libs.matrixpanel.new()

  return self

end

function mpresearch:update(dt,user,resources)
  if self:isActive() then
    self:windowupdate(dt)
    local points = resources:getValue("research")
    self:setWindowTitle("Research ("..points.."/"..resources:getCargo("research")..")")
    self._objects_select:update(dt)
    self._dangle = self._dangle + dt
    for _,button in pairs(self._current_research_buttons) do
      button:update(dt)
      button:_researchCheck(user,points)
    end
  end
end

function mpresearch:getDescText(index)
  index = index or self._currentObject
  local object_type = libs.objectrenderer.getType(index)
  local body = "\n" .. object_type.loc.build
  if object_type.class then
    body = "Class: " .. object_type.class .. "\n" .. body
  end
  return body
end

function mpresearch:getDescTextWidth()
  return self:getSubContentWidth()
end

function mpresearch:getDescTextHeight(index)
  local text_width = self:getDescTextWidth(index)
  local desc = self:getDescText(index)
  local _,text_wrappings = self._desc_font:getWrap( desc, text_width )
  return self._desc_font:getHeight()*#text_wrappings
end

function mpresearch:draw(user,resources,points)

  if self:isActive() then

    local window,content = self:windowdraw()
    -- ignore window: size is override
    -- ignore content: using subcontent

    local subcontent = {
      x=content.x+self._objects_select:getWidth()+self._padding,
      y=content.y,
      width=self:getSubContentWidth(),
      height=self:getSubContentHeight(),
    }

    if debug_mode then
      debugrect(subcontent)
    end

    local object_type = libs.objectrenderer.getType(self._currentObject)

    -- title and description
    love.graphics.setFont(fonts.large)
    local title = object_type.loc.name
    dropshadowf(title,
      subcontent.x,
      subcontent.y,
      subcontent.width,
      "left")
    local title_height = fonts.large:getHeight()
    love.graphics.setFont(fonts.default)
    dropshadowf(self:getDescText(),
      subcontent.x,
      subcontent.y+fonts.large:getHeight(),
      self:getDescTextWidth(),
      "left")
    local desc_height = self:getDescTextHeight()

    -- draw object
    self:drawObject(self._currentObject,
      subcontent.x+subcontent.width-self._drawSize, -- TODO: add tooltipdata
      subcontent.y+title_height+desc_height,
      self._drawSize,self._drawSize)
    libs.objectrenderer.tooltipBuild(
      object_type,
      subcontent.x-8,--tooltipBuild padding hack
      subcontent.y+title_height+desc_height,
      points,
      resources,
      {
        disable_tooltipbg=true,
        use_cost_header=true,
      })

    -- draw buttons
    local button_x_offset = subcontent.x + subcontent.width - self._buttonWidth--+(subcontent.width-self._buttonWidth)/2
    local button_y_offset = subcontent.y + title_height + desc_height + self._drawSize
    if #self._current_research_buttons > 0 then
      for button_index,button in pairs(self._current_research_buttons) do
        button:setX(button_x_offset)
        button:setWidth(self._buttonWidth)
        -- button:setY(button_y_offset + button:getHeight()*(button_index-1))
        button:setY(window.y+self:getHeight()-button:getHeight()-self._padding)
        button:draw()
      end
    else
      dropshadowf("No research available for this object.",
        button_x_offset,y_offset,subcontent.width,"center")
    end

    -- draw last for tooltips
    self._objects_select:setX(content.x)
    self._objects_select:setY(content.y)
    self._objects_select:draw()

    if debug_mode then
      local s = ""
      for i,v in pairs(user.research or {}) do
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

end

function mpresearch:drawObject(type,x,y,w,h)

  if debug_mode then
    debugrect(x,y,w,h)
  end

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

function mpresearch:setPlayers(val)
  self._players = val
end

function mpresearch:getPlayers(val)
  return self._players
end

function mpresearch:getWidth()
  return self._objects_select:getWidth()+self:getSubContentWidth()+self._padding*3
end

function mpresearch:getHeight()
  if true then
    return 720-32*2
  else
    local content_height = fonts.window_title:getHeight()+self._padding*2
    local a = self._objects_select:getHeight()+content_height+self._padding
    local b = fonts.window_title:getHeight()+self:getSubContentHeight()+self._padding*3
    return math.max(a,b)
  end
end

function mpresearch:getSubContentWidth()
  return 480
end

function mpresearch:getSubContentHeight()
  local buttons_height = 0
  for _,button in pairs(self._current_research_buttons) do
    buttons_height = buttons_height + button:getHeight()
  end
  return fonts.large:getHeight()+self:getDescTextHeight()+self._drawSize+buttons_height
end

function mpresearch:mousepressed(x,y,button)
  if self._objects_select:mouseInside() then
    self._objects_select:runHoverAction()
  end
end

function mpresearch:mousereleased(x,y,button)
end

function mpresearch:canAffordAnything(user,resources)
  local points = resources:get("research")
  for _,object_type in pairs(libs.researchrenderer.getUnlockedObjects(user,self._players)) do
    if not libs.researchrenderer.isUnlocked(user,object_type) and
      libs.researchrenderer.canAffordUnlock(user,object_type,points) then
      return true
    end
  end
  return false
end

function mpresearch:setGenFirst(user,players)
  print(user,players)
  local gen_render = libs.researchrenderer.getGenRender(user,players)
  if gen_render then
    self._startObject = gen_render.first
    self._currentObject = self._startObject
  end
end

function mpresearch:canUnlockAnything(user,players)
  assert(user)
  assert(players)
  local gen_render = libs.researchrenderer.getGenRender(user,players)
  local objects = libs.researchrenderer.getResearchableObjects(nil,gen_render.first)
  for _,object in pairs(objects) do
    if not libs.researchrenderer.isUnlocked(user,object) then
      return true
    end
  end
  return false
end

function mpresearch:buildData(user,resources,players)
  assert(user)
  assert(resources)
  assert(players)
  self._object_types = libs.researchrenderer.getUnlockedObjects(user,players)
  self._objects_select = libs.matrixpanel.new{
    width=self._objectsSelectWidth,
    drawbg=false,
    padding=0,
  }
  for _,object_type in pairs(self._object_types) do
    local action = self._objects_select:addAction(
      object_type.icons[1],
      function()
        self._currentObject = object_type.type
        self:buildData(user,resources,players)
      end,
      function(hover)
        local points = resources:get("research")
        if self._currentObject == object_type.type then
          return {255,255,255,hover and 255 or 191}
        elseif libs.researchrenderer.isUnlocked(user,object_type) then
          return {0,255,0,hover and 255 or 191}
        elseif libs.researchrenderer.canAffordUnlock(user,object_type,points) then
          return {0,255,255}
        else
          return {127,127,127,hover and 255 or 191}
        end
      end,
      function()
        return object_type.loc.name
      end,
      nil,
      nil,
      function()
        if self._currentObject == object_type.type then
          return {246,197,42}
        end
      end
    )
    action._research_type = object_type.type
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
    }
    button._researchCheck = function(self,user,points)
      local canAfford = libs.researchrenderer.canAffordUnlock(user,current_object_type,points)
      local isMaxLevel = current_level == research.max_level
      self:setDisabled(not canAfford or isMaxLevel)
    end
    local cost = ""
    local level = research.max_level == 1 and " " or " (max)"
    if current_level ~= research.max_level then
      cost = " ("..research.cost(current_level)..")"
      if research.max_level > 1 then
        level = " "..current_level.."/"..research.max_level
      end
    end
    button:setText(research.loc.name..cost..level)
    button:setIcon(research.icon)
    table.insert(self._current_research_buttons,button)
  end

  self._onChange(self._onChangeScope)

end

function mpresearch:getObjectSelectAction(type)
  for _,action in pairs(self._objects_select._actions) do
    if action._research_type == type then
      return action
    end
  end
end

return mpresearch
