local server = {}

function server:init()
  self.lovernet = libs.lovernet.new{type=libs.lovernet.mode.server,serdes=libs.bitser}

  self.lovernet:addOp('git_count')
  self.lovernet:addProcessOnServer('git_count',function(self,peer,arg,storage)
    return git_count
  end)

  self.lovernet:addOp('user_count')
  self.lovernet:addProcessOnServer('user_count',function(self,peer,arg,storage)
    local count = 0
    for user_index,user in pairs(self:getUsers()) do
      count = count + 1
    end
    return count
  end)

  self.lovernet:addOp('debug_create_object')
  self.lovernet:addValidateOnServer('debug_create_object',{x='number',y='number'})
  self.lovernet:addProcessOnServer('debug_create_object',function(self,peer,arg,storage)
    storage.objects_index = storage.objects_index + 1
    local object = {
      index=storage.objects_index,
      x=arg.x,
      y=arg.y,
      speed=100,
    }
    table.insert(storage.objects,object)
  end)

  self.lovernet:addOp('get_new_objects')
  self.lovernet:addValidateOnServer('get_new_objects',{i='number'})
  self.lovernet:addProcessOnServer('get_new_objects',function(self,peer,arg,storage)
    local objects = {}
    for _,object in pairs(storage.objects) do
      if object.index > arg.i then
        table.insert(objects,object)
      end
    end
    return objects
  end)

  self.lovernet:addOp('move_objects')
  self.lovernet:addValidateOnServer('move_objects',{o=function(data)
    if type(data)~='table' then
      return false,'data.o is not a table ['..tostring(data).."]"
    end
    for _,v in pairs(data) do
      if type(v.i)~='number' then
        return false,'value.i in data.o is not a number ['..tostring(v.i).."]"
      end
      if type(v.x)~='number' then
        return false,'value.y in data.o is not a number ['..tostring(v.x).."]"
      end
      if type(v.y)~='number' then
        return false,'value.x in data.o is not a number ['..tostring(v.y).."]"
      end
    end
    return true
  end})
  self.lovernet:addProcessOnServer('move_objects',function(self,peer,arg,storage)
    for _,object in pairs(storage.objects) do
      -- todo: cache indexes
      for _,sobject in pairs(arg.o) do
        if object.index == sobject.i then

          local cx,cy
          if object.tdt then
            cx,cy = libs.net.getCurrentLocation(object,love.timer.getTime())
            object.x,object.y = cx,cy
          end

          object.tx = sobject.x
          object.ty = sobject.y
          object.tdt = love.timer.getTime()
          storage.global_update_index = storage.global_update_index + 1
          local update={
            tx=object.tx,
            ty=object.ty,
            tdt = object.tdt,
          }
          if cx and cy then
            update.x,update.y = cx,cy
          end
          table.insert(storage.updates,{
            index=object.index,
            update_index = storage.global_update_index,
            update=update,
          })
        end
      end

    end
  end)

  self.lovernet:addOp('get_new_updates')
  self.lovernet:addValidateOnServer('get_new_updates',{u='number'})
  self.lovernet:addProcessOnServer('get_new_updates',function(self,peer,arg,storage)

    local user = self:getUser(peer)

    local data = {}
    data.i = storage.global_update_index
    data.u = {}
    for _,update in pairs(storage.updates) do
      if update.update_index > user.last_update then
        table.insert(data.u,{i=update.index,u=update.update})
      end
    end

    local min_last_update = math.huge
    for _,user in pairs(self:getUsers()) do
      min_last_update = math.min(min_last_update,user.last_update)
    end

    local new_updates = {}
    for _,update in pairs(storage.updates) do
      if update.update_index > min_last_update then
        table.insert(new_updates,update)
      end
    end
    storage.updates = new_updates

    -- todo: possible attack vector - force server to record all updates
    user.last_update = math.max(user.last_update,arg.u)

    return data
  end)

  self.lovernet:addOp('t')
  self.lovernet:addProcessOnServer('t',function(self,peer,arg,storage)
    return love.timer.getTime()
  end)

  self.lovernet:getStorage().objects = {}
  self.lovernet:getStorage().objects_index = 0

  self.lovernet:getStorage().updates = {}
  self.lovernet:getStorage().global_update_index = 0

  self.lovernet:onAddUser(function(user)
    user.last_update = 0
  end)

end

function server:update(dt)
  self.lovernet:update(dt)
end

function server:draw()
  str = ""
  str = str .. "objects: " .. #self.lovernet:getStorage().objects .. "\n"
  str = str .. "updates: " .. #self.lovernet:getStorage().updates .. "\n"
  str = str .. "global_update_index: " .. self.lovernet:getStorage().global_update_index .. "\n"
  for i,v in pairs(self.lovernet:getUsers()) do
    str = str .. "user["..v.name.."]: " .. v.last_update .. "\n"
  end

  love.graphics.print(str)
end

return server
