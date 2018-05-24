local client = {}

function client:init()
  self.lovernet = libs.lovernet.new{serdes=libs.bitser}
  self.lovernet:addOp('git_count')
  self.lovernet:addOp('user_count')
  self.lovernet:addOp('debug_create_object')
  self.lovernet:addOp('get_new_objects')
  self.lovernet:addOp('get_new_updates')
  self.lovernet:addOp('move_objects')
  self.lovernet:addOp('t')

  -- init
  self.lovernet:pushData('git_count')
  self.object_index = 0
  self.update_index = 0
  self.user_count = 0
  self.time = 0
  self.selection = libs.selection.new()
  self.objects = {}

end

function client:getObjectByIndex(index)
  for _,v in pairs(self.objects) do
    if v.index == index then
      return v
    end
  end
end

function client:update(dt)
  self.lovernet:pushData('get_new_objects',{i=self.object_index})
  self.lovernet:pushData('get_new_updates',{u=self.update_index})
  self.lovernet:pushData('user_count')
  self.lovernet:pushData('t')
  self.lovernet:update(dt)

  if self.lovernet:getCache('git_count') then
    self.server_git_count = self.lovernet:getCache('git_count')
  end
  if self.lovernet:getCache('user_count') then
    self.user_count = self.lovernet:getCache('user_count')
  end

  if self.lovernet:getCache('t') then
    self.time = self.lovernet:getCache('t')
  else
    self.time = self.time + dt
  end

  if self.lovernet:getCache('get_new_objects') then
    for _,sobject in pairs(self.lovernet:getCache('get_new_objects')) do
      local object = self:getObjectByIndex(sobject.index)
      if not object then

        -- init objects:
        sobject.dx = sobject.x
        sobject.dy = sobject.y

        table.insert(self.objects,sobject)
        self.object_index = math.max(self.object_index,sobject.index)
      end
    end
    self.lovernet:clearCache('get_new_objects')
  end

  if self.lovernet:getCache('get_new_updates') then
    self.update_index = self.lovernet:getCache('get_new_updates').i
    for sobject_index,sobject in pairs(self.lovernet:getCache('get_new_updates').u) do
      local object = self:getObjectByIndex(sobject.i)
      if object then
        for i,v in pairs(sobject.u) do
          object[i] = v
        end
      else
        print('Failed to update object#'..sobject.i.." (missing)")
      end
    end
  end
  self.lovernet:clearCache('get_new_updates')

  for _,object in pairs(self.objects) do
    local cx,cy = libs.net.getCurrentLocation(object,self.time)
    object.dx = (object.dx or cx) + (cx-object.dx)/2
    object.dy = (object.dy or cy) + (cy-object.dy)/2
  end

end

function client:mousepressed(x,y,button)
  if button == 1 then
    if false then -- in UI elements
    else
      self.selection:start(x,y)
    end
  elseif button == 2 then
    self.lovernet:sendData('move_objects',{
      x=love.mouse.getX(),
      y=love.mouse.getY(),
      o=self.selection:getSelectedIndexes(),
    })
  end
end

function client:mousereleased(x,y,button)
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

function client:keypressed(key)
  if key == "c" then
    self.lovernet:sendData('debug_create_object',{
      x=love.mouse.getX(),
      y=love.mouse.getY(),
    })
  end
  if key == "`" then
    debug_mode = not debug_mode
  end
end

function client:draw()

  for object_index,object in pairs(self.objects) do
    love.graphics.setColor( self.selection:isSelected(object) and {0,255,0} or {255,255,255})
    love.graphics.circle("line",object.dx,object.dy,32)
    love.graphics.setColor(255,255,255)
    if debug_mode and object.tx and object.ty then
      love.graphics.line(object.x,object.y,object.tx,object.ty)
      local cx,cy = libs.net.getCurrentLocation(object,self.time)
      love.graphics.circle('line',cx,cy,16)
      love.graphics.printf(object.index,object.dx-16,object.dy,32,"center")
    end
  end

  local str = ""
  str = str .. "time: " .. self.time .. "\n"
  str = str .. "objects: " .. #self.objects .. "\n"
  str = str .. "update_index: " .. self.update_index .. "\n"
  str = str .. "connected users: " .. self.user_count .. "\n"
  if self.server_git_count ~= git_count then
    str = str .. "mismatch: " .. git_count .. " ~= " .. tostring(self.server_git_count) .. "\n"
  end
  love.graphics.print(str)
  self.selection:draw()
end

return client
