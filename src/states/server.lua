local server = {}

-- update system will spam network if this is <=1
server._follow_update_mult = 1.2
server._shoot_update_mult = 0.8
server._gather_update_mult = 0.5

server._throttle_object_updates = 100
server._throttle_bullet_updates = 100

server._genMapDefault = {
  asteroid=100,
  scrap=100,
  station=25,
  research_pod=100,
  blackhole=10,
  cloud=25,
  cat=1,
}

server._genPlayerFirst = "command"
server._genPlayerDefault = {
  salvager=1,
  mining=2,
  habitat=1,
}

server._genResourcesDefault = {
  material = 1600,
}

function server.setupActions(storage)

  server.actions = {}

  for _,object_type in pairs(libs.objectrenderer.getTypes()) do
    local action = "build_"..object_type.type
    server.actions[action] = function(user,parent)

      if server.objectCanAfford(object_type,user) then
        server.objectBuy(object_type,user)
        -- todo: build time
        local cx,cy = libs.net.getCurrentLocation(parent,love.timer.getTime())
        local newobject = server.createObject(storage,object_type.type,cx,cy,user)
        if object_type.speed then
          newobject.tx = cx + math.random(-128,128)
          newobject.ty = cy + math.random(-128,128)
          newobject.tdt = love.timer.getTime()
          local update={
            tx=newobject.tx,
            ty=newobject.ty,
            tdt=newobject.tdt,
          }
          server:addUpdate(newobject,update)
        end
      end

    end
  end

end

function server.generateMap(storage)
  local mapsize = settings:read("map_size")
  for object_type,object_count in pairs(server._genMapDefault) do
    for i = 1,object_count do
      local x = math.random(-mapsize,mapsize)
      local y = math.random(-mapsize,mapsize)
      server.createObject(storage,object_type,x,y,nil)
    end
  end
end

function server.generatePlayer(storage,user)
  local mapsize = settings:read("map_size")
  local x = math.random(-mapsize,mapsize)
  local y = math.random(-mapsize,mapsize)
  server.createObject(storage,server._genPlayerFirst,x,y,user)
  for object_type,object_count in pairs(server._genPlayerDefault) do
    for i = 1,object_count do
      local cx = math.random(-128,128)
      local cy = math.random(-128,128)
      server.createObject(storage,object_type,x+cx,y+cy,user)
    end
  end
end

function server.updateCargo(storage,user)
  for _,object in pairs(storage.objects) do

    for _,restype in pairs(libs.net.resourceTypes) do
      user.cargo[restype] = 0
    end

    for _,object in pairs(storage.objects) do
      if object.user == user.id then
        local object_type = libs.objectrenderer.getType(object.type)
        for _,restype in pairs(libs.net.resourceTypes) do
          if object_type[restype] then
            user.cargo[restype] = user.cargo[restype] + object_type[restype]
          end
        end
      end
    end

    for _,restype in pairs(libs.net.resourceTypes) do
      if user.resources[restype] > user.cargo[restype] then
        user.resources[restype] = user.cargo[restype]
      end
    end

  end
end

function server.objectCanAfford(object_type,user)
  if object_type.cost == nil then
    return true
  end
  for restype,value in pairs(object_type.cost) do
    if user.resources[restype] < value then
      return false
    end
  end
  return true
end

function server.objectBuy(object_type,user)
  for restype,value in pairs(object_type.cost) do
    user.resources[restype] = user.resources[restype] - value
  end
end

function server.createObject(storage,type_index,x,y,user)
  local object_type = libs.objectrenderer.getType(type_index)
  storage.objects_index = storage.objects_index + 1
  local object = {
    index=storage.objects_index,
    type=type_index,
    render=libs.objectrenderer.randomRenderIndex(object_type),
    x=x,
    y=y,
    user=user and user.id or nil,
  }
  if object_type.health then
    object.health = object_type.health.max
  end
  table.insert(storage.objects,object)
  if user then
    server.updateCargo(storage,user)
  end
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

function server:addBullet(object,bullet)
  local storage = self.lovernet:getStorage()
  storage.global_bullet_index = storage.global_bullet_index + 1
  table.insert(storage.bullets,{
    index=object.index,
    bullet_index = storage.global_bullet_index,
    bullet=bullet,
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

function server:findObject(index,storage)
  if index == nil then return end
  storage = storage or self.lovernet:getStorage()
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
    server.createObject(storage,type_index,arg.x,arg.y,user)
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

    local throttle = server._throttle_object_updates
    local throttle_index = user.last_update

    local data = {}
    data.u = {}
    for _,update in pairs(storage.updates) do
      if update.update_index > user.last_update then
        throttle = throttle - 1
        if throttle < 0 then
          break
        end
        throttle_index = update.update_index
        table.insert(data.u,{i=update.index,u=update.update})
      end
    end
    data.i = throttle_index

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

  self.lovernet:addOp('get_new_bullets')
  self.lovernet:addValidateOnServer('get_new_bullets',{b='number'})
  self.lovernet:addProcessOnServer('get_new_bullets',function(self,peer,arg,storage)

    local user = self:getUser(peer)

    local throttle = server._throttle_bullet_updates
    local throttle_index = user.last_bullet

    local data = {}
    data.b = {}
    for _,bullet in pairs(storage.bullets) do
      if bullet.bullet_index > user.last_bullet then
        throttle = throttle - 1
        if throttle < 0 then
          break
        end
        throttle_index = bullet.bullet_index
        table.insert(data.b,{i=bullet.index,b=bullet.bullet})
      end
    end
    data.i = throttle_index

    local min_last_bullet = math.huge
    for _,user in pairs(self:getUsers()) do
      min_last_bullet = math.min(min_last_bullet,user.last_bullet)
    end

    -- todo: possible attack vector - force server to record all updates
    user.last_bullet = math.max(user.last_bullet,arg.b)

    return data
  end)

  self.lovernet:addOp('get_resources')
  self.lovernet:addProcessOnServer('get_resources',function(self,peer,arg,storage)
    local user = self:getUser(peer)
    local res = {}
    for _,restype in pairs(libs.net.resourceTypes) do
      res[restype] = math.floor(user.resources[restype])
    end
    return res
  end)

  self.lovernet:addOp('action')
  self.lovernet:addValidateOnServer('action',{
    a='string',
    t=function(data)
      if type(data)~='table' then
        return false,'data.t is not a table ['..tostring(data).."]"
      end
      for _,v in pairs(data) do
        if type(v)~='number' then
          return false,'value in data.t is not a number ['..tostring(v).."]"
        end
      end
      return true
    end,
  })
  self.lovernet:addProcessOnServer('action',function(self,peer,arg,storage)
    local user = self:getUser(peer)
    for _,object_id in pairs(arg.t) do
      local parent = server:findObject(object_id,storage)
      if server.actions[arg.a] then
        server.actions[arg.a](user,parent)
      end
    end
  end)

  self.lovernet:addOp('t')
  self.lovernet:addProcessOnServer('t',function(self,peer,arg,storage)
    return love.timer.getTime()
  end)

  self.lovernet:getStorage().objects = {}
  self.lovernet:getStorage().objects_index = 0

  self.lovernet:getStorage().updates = {}
  self.lovernet:getStorage().global_update_index = 0

  self.lovernet:getStorage().bullets = {}
  self.lovernet:getStorage().global_bullet_index = 0

  self.last_user_index = 0
  local lovernet_scope = self

  self.lovernet:onAddUser(function(user)
    user.resources = {}
    user.cargo = {}
    for _,restype in pairs(libs.net.resourceTypes) do
      user.resources[restype] = server._genResourcesDefault[restype] or 0
      user.cargo[restype] = 0
    end
    user.last_update = 0
    user.last_bullet = 0
    user.id = lovernet_scope.last_user_index
    lovernet_scope.last_user_index = lovernet_scope.last_user_index + 1
    -- todo: add unique names
    server.generatePlayer(self.lovernet:getStorage(),user)

  end)

  server.setupActions(self.lovernet:getStorage())

  server.generateMap(self.lovernet:getStorage())

end

-- TARGET IS

function server:targetIsSelf(object,target)
  return object.index == target.index
end

function server:targetIsAlly(object,target)
  return object.user == target.user
end

function server:targetIsEnemy(object,target)
  return target.user ~= nil and object.user ~= target.user
end

function server:targetCanBeShot(object)
  return object.health ~= nil
end

function server:targetIsNeutral(object,target)
  return target.user == nil
end

-- ACTION TARGET

function server:gotoTarget(object,target,range)
  local distance = libs.net.distance(object,target,love.timer.getTime())
  local object_type = libs.objectrenderer.getType(object.type)
  local target_type = libs.objectrenderer.getType(target.type)
  if distance > range then
    local tcx,tcy = libs.net.getCurrentLocation(target,love.timer.getTime())
    -- todo: rename w vars in a way that makes sense, I am tired.
    local wx,wy = object.tx or object.x,object.ty or object.y
    local wdistance = math.sqrt( (wx-tcx)^2 + (wy-tcy)^2 )
    if wdistance > (range) then
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

function server:shootTarget(object,target,dt)
  local distance = libs.net.distance(object,target,love.timer.getTime())
  local object_type = libs.objectrenderer.getType(object.type)
  if distance < object_type.shoot.range then
    if object.reload_dt > object_type.shoot.reload then
      object.reload_dt = 0
      local time = love.timer.getTime()
      local cx,cy = libs.net.getCurrentLocation(object,time)
      server:addBullet(object,{
        x=cx,
        y=cy,
        s=object.index,
        t=target.index,
        tdt=time,
        eta=distance/object_type.speed,
        type=object.type,
      })
    end
  end
end

-- RANGES
function server:getFollowRange(object,target)
  local object_type = libs.objectrenderer.getType(object.type)
  local target_type = libs.objectrenderer.getType(target.type)
  return (object_type.size+target_type.size)*server._follow_update_mult
end

function server:getGatherRange(object,target)
  local object_type = libs.objectrenderer.getType(object.type)
  local target_type = libs.objectrenderer.getType(target.type)
  return (object_type.size+target_type.size)*server._gather_update_mult
end

function server:getShootRange(object,target)
  local object_type = libs.objectrenderer.getType(object.type)
  return object_type.shoot.range*server._shoot_update_mult
end

function server:getUserById(id,users)
  if id == nil then return end
  for _,user in pairs(self.lovernet:getUsers()) do
    if user.id == id then
      return user
    end
  end
end

function server:changeResource(user,restype,amount)
  user.resources[restype] = user.resources[restype] + amount
  local cargo = user.cargo[restype]
  local value = user.resources[restype]
  user.resources[restype] = math.min(math.max(value,0),cargo)
end

function server:update(dt)
  self.lovernet:update(dt)
  local storage = self.lovernet:getStorage()
  for object_index,object in pairs(storage.objects) do

    object.reload_dt = (object.reload_dt or 0) + dt
    local object_type = libs.objectrenderer.getType(object.type)

    local user = self:getUserById(object.user)
    local target = self:findObject(object.target)

    if user then

      for _,restype in pairs(libs.net.resourceTypes) do
        local gen_str = restype.."_generate"
        if object_type[gen_str] then
          self:changeResource(user,restype,object_type[gen_str]*dt)
        end
      end

    end

    if target then

      local target_type = libs.objectrenderer.getType(target.type)

      if self:targetIsNeutral(object,target) then
        self:gotoTarget(object,target,server:getGatherRange(object,target))
      elseif self:targetIsSelf(object,target) then
        self:stopUpdateObject(object)
      elseif self:targetIsAlly(object,target) then
        self:gotoTarget(object,target,server:getFollowRange(object,target))
      elseif self:targetIsEnemy(object,target) then
        if self:targetCanBeShot(object) and object_type.shoot then
          self:gotoTarget(object,target,server:getShootRange(object,target))
          self:shootTarget(object,target,dt)
        else
          self:gotoTarget(object,target,server:getFollowRange(object,target))
        end
      end

      if user then

        local distance = libs.net.distance(object,target,love.timer.getTime())
        local follow_distance = (object_type.size+target_type.size)*server._gather_update_mult

        if distance < follow_distance then
          for _,restype in pairs(libs.net.resourceTypes) do
            local gather_str = restype.."_gather"
            local supply_str = restype.."_supply"
            if object_type[gather_str] and target_type[supply_str] then
              target[supply_str] = target[supply_str] or target_type[supply_str]
              local amount = object_type[gather_str]*dt
              local space_remaining = user.cargo[restype] - user.resources[restype]
              if amount > space_remaining then
                amount = space_remaining
              end
              if amount > target[supply_str] then
                amount = target[supply_str]
              end
              target[supply_str] = math.max(0,target[supply_str] - amount)
              self:changeResource(user,restype,amount)
              print(amount,target[supply_str])
              if target[supply_str] == 0 then
                local update = {}
                update[supply_str] = 0
                server:addUpdate(target,update)
              end
            end
          end

        end

      end -- end user

    else -- end target
      --nop
    end

    if libs.net.objectShouldBeRemoved(object) then
      table.remove(storage.objects,object_index)
      if user then
        self.updateCargo(storage,user)
      end
    end

  end

  for bullet_index,bullet in pairs(storage.bullets) do
    local remove_bullet = false
    local target = self:findObject(bullet.bullet.t)
    if target then
      local time = love.timer.getTime()
      local target_type = libs.objectrenderer.getType(target.type)
      local cbx,cby,ctx,cty = libs.net.getCurrentBulletLocation(bullet.bullet,target,time)
      local distance = math.sqrt( (cbx-ctx)^2 + (cby-cty)^2 )
      if distance < target_type.size/2 then
        remove_bullet = true
        local object_type = libs.objectrenderer.getType(bullet.bullet.type)
        target.health = math.max(0,target.health - object_type.shoot.damage)
        self:addUpdate(target,{
          health=target.health,
        })
      end
    else
      remove_bullet = true
    end
    if remove_bullet then
      table.remove(storage.bullets,bullet_index)
    end
  end

end

function server:draw()
  str = ""
  str = str .. "time: " .. math.floor(love.timer.getTime()) .. "\n"
  str = str .. "objects: " .. #self.lovernet:getStorage().objects .. "\n"
  str = str .. "updates: " .. #self.lovernet:getStorage().updates .. "\n"
  str = str .. "global_update_index: " .. self.lovernet:getStorage().global_update_index .. "\n"
  str = str .. "bullets: " .. #self.lovernet:getStorage().bullets .. "\n"
  str = str .. "global_bullet_index: " .. self.lovernet:getStorage().global_bullet_index .. "\n"
  for i,v in pairs(self.lovernet:getUsers()) do
    str = str .. "user["..v.name.."]: " .. v.last_update .. "\n"
  end

  love.graphics.print(str)
end

return server
