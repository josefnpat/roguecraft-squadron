local server = {}

server._follow_update_mult = 2

server._genDefault = {
  asteroid=100,
  scrap=100,
  station=25,
  research_pod=100,
  blackhole=10,
  cloud=25,
  cat=1,
}

function server.generateMap(storage)
  local mapsize = settings:read("map_size")
  for object_type,object_count in pairs(server._genDefault) do
    for i = 1,object_count do
      local x = math.random(-mapsize,mapsize)
      local y = math.random(-mapsize,mapsize)
      server.createObject(storage,object_type,x,y,nil)
    end
  end
end

function server.createObject(storage,type_index,x,y,user_id)
  local type = libs.objectrenderer.getType(type_index)
  storage.objects_index = storage.objects_index + 1
  local object = {
    index=storage.objects_index,
    type=type_index,
    render=libs.objectrenderer.randomRenderIndex(type),
    x=x,
    y=y,
    user=user_id,
  }
  table.insert(storage.objects,object)
  return object
end

function server:addUpdate(object,update)
  local storage = self.lovernet:getStorage()
  storage.global_update_index = storage.global_update_index + 1
  table.insert(storage.updates,{
    index=object.index,
    update_index = storage.global_update_index,
    update=update,
  })
end

function server:stopObject(object)
  local cx,cy = libs.net.getCurrentLocation(object,love.timer.getTime())
  object.x,object.y = cx,cy
  object.tx,object.ty,object.tdt = nil,nil,nil
  return cx,cy
end

function server:stopUpdateObject(object)
  if object.tx and object.ty and object.tdt then
    local cx,cy = self:stopObject(object)
    self:addUpdate(object,{
      x=cx,
      y=cy,
      tx="nil",
      ty="nil",
      tdt="nil",
    })
  end
end

function server:findObject(index)
  local storage = self.lovernet:getStorage()
  for _,object in pairs(storage.objects) do
    if object.index == index then
      return object
    end
  end
end

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

  self.lovernet:addOp('get_user')
  self.lovernet:addProcessOnServer('get_user',function(self,peer,arg,storage)
    local user = self:getUser(peer)
    return {id=user.id}
  end)

  self.lovernet:addOp('debug_create_object')
  self.lovernet:addValidateOnServer('debug_create_object',{x='number',y='number'})
  self.lovernet:addProcessOnServer('debug_create_object',function(self,peer,arg,storage)
    local user = self:getUser(peer)
    local type_index = "debug"
    server.createObject(storage,type_index,arg.x,arg.y,user.id)
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
    -- todo: ensure all objects being moved are by the correct user
    local user = self:getUser(peer)

    for _,object in pairs(storage.objects) do
      -- todo: cache indexes
      for _,sobject in pairs(arg.o) do
        local type = libs.objectrenderer.getType(object.type)
        if object.index == sobject.i and type.speed then
          local cx,cy = server:stopObject(object)
          local mapsize = settings:read("map_size")
          object.tx = math.min(math.max(-mapsize,sobject.x),mapsize)
          object.ty = math.min(math.max(-mapsize,sobject.y),mapsize)
          object.tdt = love.timer.getTime()
          object.target = nil
          local update={
            tx=object.tx,
            ty=object.ty,
            tdt = object.tdt,
            target = "nil",
          }
          if cx and cy then
            update.x,update.y = cx,cy
          end
          server:addUpdate(object,update)
        end
      end

    end
  end)

  self.lovernet:addOp('target_objects')
  self.lovernet:addValidateOnServer('target_objects',{t=function(data)
    if type(data)~='table' then
      return false,'data.t is not a table ['..tostring(data).."]"
    end
    for _,v in pairs(data) do
      if type(v.i)~='number' then
        return false,'value.i in data.t is not a number ['..tostring(v.i).."]"
      end
      if type(v.t)~='number' then
        return false,'value.t in data.t is not a number ['..tostring(v.t).."]"
      end
    end
    return true
  end})
  self.lovernet:addProcessOnServer('target_objects',function(self,peer,arg,storage)
    for _,object in pairs(storage.objects) do
      -- todo: cache indexes
      for _,sobject in pairs(arg.t) do
        if object.index == sobject.i then
          object.target = sobject.t
          server:addUpdate(object,{
            target = object.target,
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

  self.last_user_index = 0
  local lovernet_scope = self

  self.lovernet:onAddUser(function(user)
    user.last_update = 0
    user.id = lovernet_scope.last_user_index
    lovernet_scope.last_user_index = lovernet_scope.last_user_index + 1
    -- todo: add unique names
  end)

  server.generateMap(self.lovernet:getStorage())

end

function server:targetIsSelf(object,target)
  if object.index == target.index then
    self:stopUpdateObject(object)
  end
end

function server:targetIsAlly(object,target)
  if object.user == target.user then
    local distance = libs.net.distance(object,target,love.timer.getTime())
    local object_type = libs.objectrenderer.getType(object.type)
    local target_type = libs.objectrenderer.getType(target.type)
    local sub_distance = object_type.size+target_type.size
    if distance > sub_distance then
      local tcx,tcy = libs.net.getCurrentLocation(target,love.timer.getTime())
      -- todo: rename w vars in a way that makes sense, I am tired.
      local wx,wy = object.tx or object.x,object.ty or object.y
      local wdistance = math.sqrt( (wx-tcx)^2 + (wy-tcy)^2 )
      if wdistance > (sub_distance)*server._follow_update_mult then
        local cx,cy = self:stopObject(object)
        object.tx = tcx
        object.ty = tcy
        object.tdt = love.timer.getTime()
        self:addUpdate(object,{
          x=cx,
          y=cy,
          tx=object.tx,
          ty=object.ty,
          tdt=object.tdt,
        })
      end
    else
      self:stopUpdateObject(object)
    end
  end
end

function server:targetIsNeutral(object,target)
  -- todo
end

function server:update(dt)
  self.lovernet:update(dt)
  local storage = self.lovernet:getStorage()
  for _,object in pairs(storage.objects) do
    local target = self:findObject(object.target)
    if target then
      self:targetIsSelf(object,target)
      self:targetIsAlly(object,target)
      self:targetIsNeutral(object,target)
    else -- target == nil
      --nop
    end
  end
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
