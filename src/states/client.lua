local client = {}

function client:init()
  self.lovernet = libs.lovernet.new{serdes=libs.bitser}
  -- todo: make common functions use short names
  self.lovernet:addOp('git_count')
  self.lovernet:addOp('user_count')
  self.lovernet:addOp('get_user')
  self.lovernet:addOp('debug_create_object')
  self.lovernet:addOp('get_new_objects')
  self.lovernet:addOp('get_new_updates')
  self.lovernet:addOp('move_objects')
  self.lovernet:addOp('t')

  -- init
  self.lovernet:pushData('git_count')
  self.lovernet:pushData('get_user')
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
    self.lovernet:clearCache('git_count')
  end

  if self.lovernet:getCache('user_count') then
    self.user_count = self.lovernet:getCache('user_count')
  end

  if self.lovernet:getCache('get_user') then
    self.user = self.lovernet:getCache('get_user')
    self.lovernet:clearCache('get_user')
    self.selection:setUser(self.user.id)
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
    self.lovernet:clearCache('get_new_updates')
  end


  for _,object in pairs(self.objects) do
    local cx,cy = libs.net.getCurrentLocation(object,self.time)
    object.dx = (object.dx or cx) + (cx-object.dx)/2
    object.dy = (object.dy or cy) + (cy-object.dy)/2
  end

end

function CartArchSpiral(initRad,turnDistance,angle)
  local x = (initRad+turnDistance*angle)*math.cos(angle)
  local y = (initRad+turnDistance*angle)*math.sin(angle)
  return x,y
end

function client:distanceTarget(a,b)
  local ax = a._ttx or a.tx or a.x
  local ay = a._tty or a.ty or a.y
  local bx = b._ttx or b.tx or b.x
  local by = b._tty or b.ty or b.y
  return math.sqrt( (ax - bx)^2  + (ay - by)^2 )
end

function client:findNearestTarget(objects,x,y)
  local nearest,nearest_distance = nil,math.huge
  for _,object in pairs(objects) do
    if object.tx ~= x and object.ty ~= y then
      local distance = self:distanceTarget({tx=x,ty=y},object)
      if distance < nearest_distance then
        nearest,nearest_distance = object,distance
      end
    end
  end
  return nearest,nearest_distance
end

function client:mousepressed(x,y,button)
  if button == 1 then
    if false then -- in UI elements
    else
      self.selection:start(x,y)
    end
  elseif button == 2 then
    local moves = {}
    local curAngle = 0
    local selected = self.selection:getSelected()
    local unselected = self.selection:getUnselected(self.objects)
    for _,object in pairs(self.selection:getSelected()) do

      local tx,ty = x,y
      if #selected > 1 then
        local cx,cy
        repeat
          cx,cy = CartArchSpiral(8,8,curAngle)
          local n,nd = client:findNearestTarget(
            unselected,
            cx+love.mouse.getX(),
            cy+love.mouse.getY()
          )
          curAngle = curAngle + math.pi/32
        until n == nil or nd > 48
        object._ttx=cx+love.mouse.getX()
        object._tty=cy+love.mouse.getY()
        tx,ty = cx+love.mouse.getX(),cy+love.mouse.getY()
      end

      table.insert(unselected,object)

      table.insert(moves,{
        i=object.index,
        x=tx,
        y=ty,
      })
      curAngle = curAngle + math.pi/32
    end
    self.lovernet:sendData('move_objects',{o=moves})
    for _,object in pairs(self.selection:getSelected()) do
      object._ttx,object._tty = nil,nil
    end
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
    if self.selection:isSelected(object) then
      love.graphics.setColor(libs.net.getUser(object.user).selected_color)
    else
      love.graphics.setColor(libs.net.getUser(object.user).color)
    end
    love.graphics.circle("line",object.dx,object.dy,32)
    love.graphics.setColor(255,255,255)
    if debug_mode then
      if object.tx and object.ty then
        love.graphics.line(object.x,object.y,object.tx,object.ty)
        local cx,cy = libs.net.getCurrentLocation(object,self.time)
        love.graphics.circle('line',cx,cy,16)
      end
      local str = ""
      str = str .. "index: " .. object.index .. "\n"
      str = str .. "user: " .. libs.net.getUser(object.user).name .. "["..object.user.."]\n"
      love.graphics.printf(str,object.dx-64,object.dy,128,"center")
    end
  end

  local str = ""
  if self.user then
    str = str .. "user.id: " .. libs.net.getUser(self.user.id).name .. "["..self.user.id.."]\n"
    love.graphics.setColor(255,255,255)
  else
    str = str .. "loading user ... \n"
  end
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
