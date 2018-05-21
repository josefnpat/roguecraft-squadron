local lovernet = {}

function lovernet:init()
  self.lovernet = libs.lovernet.new{serdes=libs.bitser}
  self.lovernet:addOp('git_count')
  self.lovernet:addOp('user_count')
  self.lovernet:addOp('debug_create_object')
  self.lovernet:addOp('get_new_objects')

  -- init
  self.lovernet:pushData('git_count')
  self.object_index = 0

  self.selection = libs.selection.new()
  self.objects = {}

end

function lovernet:update(dt)
  self.lovernet:pushData('get_new_objects',{index=self.object_index})
  self.lovernet:pushData('user_count')
  self.lovernet:update(dt)
  if love.keyboard.isDown("c") then
    self.lovernet:sendData('debug_create_object',{
      x=love.mouse.getX(),
      y=love.mouse.getY(),
    })
  end

  if self.lovernet:getCache('get_new_objects') then
    for _,object in pairs(self.lovernet:getCache('get_new_objects')) do
      table.insert(self.objects,object)
      self.object_index = math.max(self.object_index,object.index)
    end
    self.lovernet:clearCache('get_new_objects')
  end

end

function lovernet:mousepressed(x,y,button)
  if button == 1 then
    if false then -- in UI elements
    else
      self.selection:start(x,y)
    end
  end
end

function lovernet:mousereleased(x,y,button)
  if button == 1 then
    if false then -- in UI elements
    else
      if love.keyboard.isDown('lshift') then
        self.selection:endAdd(x,y,self.objects)
      else
        self.selection:endSet(x,y,self.objects)
      end
    end
  end
end

function lovernet:draw()

  for object_index,object in pairs(self.objects) do
    love.graphics.setColor(255,255,255)
    if self.selection:isSelected(object) then
      love.graphics.setColor(0,255,0)
    end
    love.graphics.print(object_index,object.x,object.y)
    love.graphics.circle("line",object.x,object.y,32)
    love.graphics.setColor(255,255,255)
  end

  local str = ""
  if self.lovernet:getCache('git_count') ~= git_count then
    str = str .. "mismatch: " ..
      git_count .. " ~= " .. (self.lovernet:getCache('git_count') or "nil") .. "\n"
  end
  if self.lovernet:getCache('user_count') then
    str = str .. "connected users: " .. self.lovernet:getCache('user_count') .. "\n"
  end
  str = str .. "objects: " .. #self.objects .. "\n"
  love.graphics.print(str)
  self.selection:draw()
end

return lovernet
