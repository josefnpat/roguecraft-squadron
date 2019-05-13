local tutorial = {}

tutorial.image = love.graphics.newImage("assets/hud/guide.png")

function tutorial.new(init)
  init = init or {}
  local self = libs.drawable.new(init)

  self.draw = tutorial.draw
  self.update = tutorial.update
  self._objectives = {}
  self.addObjective = tutorial.addObjective
  self.clear = tutorial.clear
  self._active = false
  self.setActive = tutorial.setActive
  self.mouseInside = tutorial.mouseInside

  self._font = init.font or fonts.default
  self._image = init.image or tutorial.image
  self._padding = init.padding or 8
  self._objectiveHeight = init.objectiveHeight or 40
  self._textPercent = 0

  -- self._x = 32
  -- self.getX = tutorial.getX
  -- self.setX = tutorial.setX
  -- self._y = 32
  -- self.getY = tutorial.getY
  -- self.setY = tutorial.setY
  self._width = 320
  -- self.getWidth = tutorial.getWidth
  -- self.setWidth = tutorial.setWidth
  self.activeObjectiveCount = tutorial.activeObjectiveCount
  self.getHeight = tutorial.getHeight

  return self
end

function tutorial:draw(camera)
  if self._active then

    local height = self:getHeight()
    local top_height = self._image:getHeight()+self._padding*2

    if self._currentObjective then
      local target = self._currentObjective:getTarget()
      if target then
        love.graphics.setColor(0,255,255)
        local sx,sy = libs.net.getCurrentLocation(target)
        local tx = sx-camera.x+love.graphics.getWidth()/2
        local ty = sy-camera.y+love.graphics.getHeight()/2
        love.graphics.line(self._x,self._y+height,tx,ty)
      end
      local hint = self._currentObjective:getHint()
      if hint then
        hint:drawHint()
      end
    end

    tooltipbg(self._x,self._y,self._width,height)

    if self._currentObjective then
      love.graphics.setFont(self._font)
      local text_width = self._width-self._padding*3-self._image:getWidth()
      local obj_text = self._currentObjective:getText()
      local width, wrapped_text = self._font:getWrap(obj_text,text_width)
      local text_height = #wrapped_text*self._font:getHeight()
      local text_offset = (self._image:getHeight()-text_height)/2
      dropshadowf(string.sub(obj_text,1,string.len(obj_text)*self._textPercent),
        self._x+self._padding,
        self._y+text_offset,
        text_width,
        "left")
    end

    love.graphics.setColor(255,255,255)
    love.graphics.draw(self._image,
      self._x+self._width-self._image:getWidth()-self._padding,
      self._y+self._padding)

    for objective_index,objective in pairs(self._objectives) do
      objective:draw(
        self._x,self._y+top_height+self._objectiveHeight*(objective_index-1),
        self._width,self._objectiveHeight)
      if objective == self._currentObjective then
        break
      end
    end

  end
end

function tutorial:update(dt)
  if self._active then

    self._textPercent = math.min(1,self._textPercent + dt/4)

    local found_current = nil
    for objective_index,objective in pairs(self._objectives) do
      if objective == self._currentObjective then
        found_current = true
        objective._bar:setAlpha(255)
      else
        if found_current then
          objective._bar:setAlpha(63)
        else
          objective:updateFade(dt)
          if objective:getFade() <= 0 then
            table.remove(self._objectives,objective_index)
          end
        end
      end
      objective._bar:update(dt)
    end

    if self._currentObjective then

      self._currentObjective:update(dt)
      -- set up next objective
      local complete, percent = self._currentObjective:getValue()
      if complete then
        self._currentObjective:onComplete()
        self._currentObjective:update(dt)
        self._textPercent = 0
        libs.sfx.play("widget.success")
        local nextObjective = nil
        for objectiveIndex,objective in pairs(self._objectives) do
          if objective == self._currentObjective then
            nextObjective = self._objectives[objectiveIndex+1]
            break
          end
        end
        self._currentObjective = nextObjective
      end

    end

  end
end

function tutorial:addObjective(objective)
  table.insert(self._objectives,objective)
  self._currentObjective = self._currentObjective or objective
end

function tutorial:clear()
  self._objectives = {}
  self._currentObjective = nil
end

function tutorial:setActive(val)
  self._active = val
end

function tutorial:mouseInside()
  if self._active then
    local mx,my = love.mouse.getPosition()
    return mx >= self._x and mx < self._x + self._width and
      my >= self._y and my < self._y + self:getHeight()
  end
  return false
end

-- function tutorial:getX()
--   return self._x
-- end
--
-- function tutorial:setX(val)
--   self._x = val
-- end
--
-- function tutorial:getY()
--   return self._y
-- end
--
-- function tutorial:setY(val)
--   self._y = val
-- end
--
-- function tutorial:getWidth()
--   return self._width
-- end
--
-- function tutorial:setWidth(val)
--   self._width = val
-- end

function tutorial:activeObjectiveCount()
  local count = 0
  for _,objective in pairs(self._objectives) do
    if objective == self._currentObjective then
      return count+1
    end
    count = count + 1
  end
  return count
end

function tutorial:getHeight()
  return self._image:getHeight()+self._padding*2+self._objectiveHeight*self:activeObjectiveCount()
end

return tutorial
