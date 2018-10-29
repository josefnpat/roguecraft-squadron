local server = {}

-- update system will spam network if this is <=1
server._follow_update_mult = 1.2
server._shoot_update_mult = 0.8
server._gather_update_mult = 0.5

server._gather_refresh = 2

server._throttle_object_updates = math.huge
server._throttle_bullet_updates = math.huge

server._debris_ratio = 0.5

server._genMapDefault = {
  scrap=100,
  station=16,
  asteroid=50,
  cat=1,
}
server._genEveryObjectOverride = false

server._genResourcesDefault = {
  material = math.huge,
  crew = math.huge,
}

server._maxUserUnits = math.huge
server.maxPlayers = 8

server._bump_cell_size = 64

function server.setupActions(storage)

  server.actions = {}

  for _,object_type in pairs(libs.objectrenderer.getTypes()) do
    local action = "build_"..object_type.type
    server.actions[action] = function(user,parent)

      -- lazy init to prevent tons of extra tables

      if parent.build_queue == nil and server.objectCanAfford(object_type,user,storage) then
        local build_time = storage.config.creative and 0 or object_type.build_time
        server.objectBuy(object_type,user,storage)
        server:addUpdate(parent,{
          build_t=build_time,
        },"setupActions build_time")
        parent.build_queue = {
          dt = build_time or 0,
          onDone = function()
            local cx,cy = libs.net.getCurrentLocation(parent,love.timer.getTime())
            for i = 1,(object_type.count or 1) do
              local x = cx + math.random(-object_type.size,object_type.size)
              local y = cy + math.random(-object_type.size,object_type.size)
              local newobject = server.createObject(storage,object_type.type,x,y,user)
              newobject.unqueue_parent = parent.index
              if object_type.speed then
                newobject.tx = cx + math.random(-128,128)
                newobject.ty = cy + math.random(-128,128)
                newobject.tdt = love.timer.getTime()
                local update={
                  tx=newobject.tx,
                  ty=newobject.ty,
                  tdt=newobject.tdt,
                }
                server:addUpdate(newobject,update,"setupActions onDone")
              end
            end
          end
        }
      end

    end
  end

end

server.maps = {}

server.maps.random = {
  config = {},
}

function server.maps.random.generate(storage,config)
  for object_type,object_count in pairs(server._genMapDefault) do
    for i = 1,object_count do
      local x = math.random(-libs.net.mapsize,libs.net.mapsize)
      local y = math.random(-libs.net.mapsize,libs.net.mapsize)
      server.createObject(storage,object_type,x,y,nil)
    end
  end
end

server.maps.spacedpockets = {
  config = {
    attemptRatio = 10,
    size = 1024/2,
    range = 1024*2,
    count = 8,
  },
}

function server.maps.spacedpockets.generate(storage,config)

  local pocketAttempt = 0

  local newPocket = function()
    local x = math.random(-libs.net.mapsize+config.size,libs.net.mapsize-config.size)
    local y = math.random(-libs.net.mapsize+config.size,libs.net.mapsize-config.size)
    return {x=x,y=y}
  end

  local distancePocket = function(a,b)
    return math.sqrt( (a.x - b.x)^2 + (a.y - b.y)^2 )
  end

  local validPocket = function(pockets,pocket)
    for _,opocket in pairs(pockets) do
      if distancePocket(pocket,opocket) < config.range - pocketAttempt*config.attemptRatio then
        return false
      end
    end
    return true
  end

  local pockets = {newPocket()}
  while #pockets < config.count do
    local pocket = newPocket()
    if validPocket(pockets,pocket) then
      table.insert(pockets,pocket)
    end
    pocketAttempt = pocketAttempt + 1
  end

  -- print("pocket creation attempts:"..tostring(pocketAttempt))

  for object_type,object_count in pairs(server._genMapDefault) do
    for i = 1,object_count do
      local pocket = pockets[math.random(#pockets)]
      local t = math.pi*2*math.random()
      local r = math.random(-config.size,config.size)
      local x = r*math.cos(t)+pocket.x
      local y = r*math.sin(t)+pocket.y
      server.createObject(storage,object_type,x,y,nil)
    end
  end

  return pockets

end

function server.generatePlayer(storage,user,pocket)
  local x,y
  if pocket then
    local t = math.random()*math.pi*2
    x = pocket.x + math.cos(t)*512
    y = pocket.y + math.sin(t)*512
  else
    x = math.random(-libs.net.mapsize,libs.net.mapsize)
    y = math.random(-libs.net.mapsize,libs.net.mapsize)
  end
  local preset = libs.mppresets.getPresets()[storage.config.preset]
  server.createObject(storage,preset.gen.first,x,y,user)

  local genlist = preset.gen.default
  if server._genEveryObjectOverride then
    genlist = libs.objectrenderer.getTypes()
  end
  for object_type,count in pairs(genlist) do
    for _ = 1,type(count) == "number" and count or 1 do
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
      if libs.net.userOwnsObject(user,object) then
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

function server.objectCanAfford(object_type,user,storage)
  if user.count >= server._maxUserUnits then
    return false
  end
  if not libs.net.hasPoints(user.points,storage.config.points,object_type) then
    return false
  end
  if storage.config.creative then
    return true
  end
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

function server.objectBuy(object_type,user,storage)
  if storage.config.creative then
    return
  end
  if object_type.cost then
    for restype,value in pairs(object_type.cost) do
      user.resources[restype] = user.resources[restype] - value
    end
  end
end

function server.createObject(storage,type_index,x,y,user)
  local object_type = libs.objectrenderer.getType(type_index)
  storage.objects_index = storage.objects_index + 1
  local object = {
    index=storage.objects_index,
    type=type_index,
    render=libs.objectrenderer.randomRenderIndex(object_type),
    name=libs.objectrenderer.randomNameIndex(object_type),
    x=x,
    y=y,
    user=user and user.id or nil,
  }
  if object_type.health then
    object.health = object_type.health.max
  end

  local object_type = libs.objectrenderer.getType(object.type)
  local size = (object_type.fow or 1)*1024
  storage.world:add(object,x-size/2,y-size/2,size,size)

  table.insert(storage.objects,object)
  if user then
    user.count = (user.count or 0) + 1
    user.points = (user.points or 0) + (object_type.points or 1)
    server.updateCargo(storage,user)
  end
  return object
end

function server:addUpdate(object,update,feature)
  local storage = self.lovernet:getStorage()
  storage.global_update_index = storage.global_update_index + 1
  table.insert(storage.updates,{
    index=object.index,
    update_index = storage.global_update_index,
    update=update,
  })
  feature = feature or "N/A"
  server._addUpdateProfile[feature] = (server._addUpdateProfile[feature] or 0) + 1
end

function server:addGather(dt,object,amount)
  if amount > 0 then
    if object.gather_dt == nil then
      server:addUpdate(object,{gather=1},"addGather")
      object.gather_dt = 0
    else
      object.gather_dt = object.gather_dt + dt
      if object.gather_dt >= server._gather_refresh then
        object.gather_dt = nil
      end
    end
  end
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
  object.tx,object.ty,object.tdt,object.tint = nil,nil,nil,nil
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
    },"stopUpdateObject")
  end
end

function server:stopUpdateObjectTarget(object)
  if object.target then
    object.target = nil
    self:addUpdate(object,{
      target="nil",
    },"stopUpdateObjectTarget")
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

function server:generatePlayers(users,storage)
  local players = {}
  for index_player,real_player in pairs(users) do
    real_player.config = real_player.config or {
      id=real_player.id,
      team=#players+1
    }
    if string.sub(index_player,1,3) == "ai_" then
      if not storage.ai_are_connected then
        table.insert(players,real_player.config)
      end
    else
      table.insert(players,real_player.config)
    end
  end
  if storage.config.ai then
    for ai_index = 1,storage.config.ai do
      storage.ai_players[ai_index] = storage.ai_players[ai_index] or {
        config={
          ai=ai_index,
          team=#players+1,
          diff=1,
        }
      }
      table.insert(players,storage.ai_players[ai_index].config)
    end
  end
  return players
end

function server:init()
  self.lovernet = nil

  -- Just keep trying to connect until lovernet is dead
  local temp_log_data,lovernet_log
  local function temp_lovernet_log(self,...)
    local args = {...}
    table.insert(temp_log_data,args)
  end
  while self.lovernet == nil do
    temp_log_data = {}
    self.lovernet = libs.lovernet.new{
      type=libs.lovernet.mode.server,
      serdes=libs.bitser,
      log=temp_lovernet_log,
    }
  end
  self.lovernet.log = libs.lovernet.log
  for _,entry in pairs(temp_log_data) do
    self.lovernet:log(unpack(entry))
  end
  -- end of hack

  self.lovernet:addOp(libs.net.op.git_count)
  self.lovernet:addProcessOnServer(libs.net.op.git_count,function(self,peer,arg,storage)
    return git_count
  end)

  self.lovernet:addOp(libs.net.op.user_count)
  self.lovernet:addProcessOnServer(libs.net.op.user_count,function(self,peer,arg,storage)
    local count = 0
    for user_index,user in pairs(self:getUsers()) do
      count = count + 1
    end
    return count
  end)

  self.lovernet:addOp(libs.net.op.get_user)
  self.lovernet:addProcessOnServer(libs.net.op.get_user,function(self,peer,arg,storage)
    local user = self:getUser(peer)
    return {id=user.id,np=user.not_playing}
  end)

  self.lovernet:addOp(libs.net.op.get_config)
  self.lovernet:addProcessOnServer(libs.net.op.get_config,function(self,peer,arg,storage)
    return storage.config
  end)

  self.lovernet:addOp(libs.net.op.set_config)
  self.lovernet:addValidateOnServer(libs.net.op.set_config,{d='table'})
  self.lovernet:addProcessOnServer(libs.net.op.set_config,function(self,peer,arg,storage)
    for i,v in pairs(arg.d) do
      storage.config[i] = v
    end
    server:validateConfig()
  end)

  self.lovernet:addOp(libs.net.op.get_players)
  self.lovernet:addProcessOnServer(libs.net.op.get_players,function(self,peer,arg,storage)
    return server:generatePlayers(self:getUsers(),storage)
  end)

  self.lovernet:addOp(libs.net.op.set_players)
  self.lovernet:addValidateOnServer(libs.net.op.set_players,{t='string',p='number',d='table'})
  self.lovernet:addProcessOnServer(libs.net.op.set_players,function(self,peer,arg,storage)

    local player
    if arg.t == "u" then
      player = libs.net.getPlayerById(self:getUsers(),arg.p)
    else -- arg.t == "ai"
      player = libs.net.getPlayerByAi(self:getStorage().ai_players,arg.p)
    end

    if player then
      for i,v in pairs(arg.d) do
        player.config[i] = v
      end
      server:validatePlayerConfig(player.config)
    else
      print("Could not find player",arg.t,arg.p)
    end

  end)

  self.lovernet:addOp(libs.net.op.get_research)
  self.lovernet:addProcessOnServer(libs.net.op.get_research,function(self,peer,arg,storage)
    local user = self:getUser(peer)
    return user.research
  end)

  self.lovernet:addOp(libs.net.op.set_research)
  self.lovernet:addValidateOnServer(libs.net.op.set_research,{o='string',r='string',v="number"})
  self.lovernet:addProcessOnServer(libs.net.op.set_research,function(self,peer,arg,storage)
    local user = self:getUser(peer)
    -- todo: check if object is unlockable
    local points = user.resources["research"]
    local success,cost = libs.researchrenderer.buyLevel(user,arg.o,arg.r,arg.v,points)
    if success then
      user.resources["research"] = user.resources["research"] - cost
    end
  end)

  self.lovernet:addOp(libs.net.op.debug_create_object)
  self.lovernet:addValidateOnServer(libs.net.op.debug_create_object,{x='number',y='number',c='number'})
  self.lovernet:addProcessOnServer(libs.net.op.debug_create_object,function(self,peer,arg,storage)
    local user = self:getUser(peer)
    local type_index = "debug"
    for i = 1,arg.c do
      server.createObject(storage,type_index,arg.x,arg.y,user)
    end
  end)

  self.lovernet:addOp(libs.net.op.delete_objects)
  self.lovernet:addValidateOnServer(libs.net.op.delete_objects,{d=function(data)
    if type(data)~='table' then
      return false,'data.d is not a table ['..tostring(data).."]"
    end
    for _,v in pairs(data) do
      if type(v)~='number' then
        return false,'value in data.o is not a number ['..tostring(v.i).."]"
      end
    end
    return true
  end})
  self.lovernet:addValidateOnServer(libs.net.op.delete_objects,{d='table'})
  self.lovernet:addProcessOnServer(libs.net.op.delete_objects,function(self,peer,arg,storage)
    local user = self:getUser(peer)

    for _,object in pairs(storage.objects) do
      -- todo: cache indexes
      for _,sobject_index in pairs(arg.d) do
        if object.index == sobject_index and libs.net.userOwnsObject(user,object) then
          server:addUpdate(object,{remove=true},"delete_objects")
          object.remove = true
        end
      end
    end
  end)

  local object_field_exceptions = {"build_queue"}
  local function isNotException(val)
    for _,exception_value in pairs(object_field_exceptions) do
      if val == exception_value then
        return false
      end
    end
    return true
  end

  self.lovernet:addOp(libs.net.op.get_new_objects)
  self.lovernet:addValidateOnServer(libs.net.op.get_new_objects,{i='number'})
  self.lovernet:addProcessOnServer(libs.net.op.get_new_objects,function(self,peer,arg,storage)
    local objects = {}
    for _,object in pairs(storage.objects) do
      if object.index > arg.i then
        local temp = {}
        for i,v in pairs(object) do
          if isNotException(i) then
            temp[i] = v
          end
        end
        table.insert(objects,temp)
      end
    end
    return objects
  end)

  self.lovernet:addOp(libs.net.op.move_objects)
  self.lovernet:addValidateOnServer(libs.net.op.move_objects,{int="boolean",o=function(data)
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
  self.lovernet:addProcessOnServer(libs.net.op.move_objects,function(self,peer,arg,storage)
    local user = self:getUser(peer)
    -- todo: cache indexes
    for _,sobject in pairs(arg.o) do
      local object = libs.net.getObjectByIndex(storage.objects,sobject.i)
      if object and libs.net.userOwnsObject(user,object) then
        libs.net.moveToTarget(server,object,sobject.x,sobject.y,arg.int)
      end
    end
  end)

  self.lovernet:addOp(libs.net.op.target_objects)
  self.lovernet:addValidateOnServer(libs.net.op.target_objects,{t=function(data)
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
  self.lovernet:addProcessOnServer(libs.net.op.target_objects,function(self,peer,arg,storage)
    local user = self:getUser(peer)

    for _,object in pairs(storage.objects) do
      -- todo: cache indexes
      for _,sobject in pairs(arg.t) do
        if object.index == sobject.i and libs.net.userOwnsObject(user,object) then
          libs.net.setObjectTarget(server,object,sobject.t)
        end
      end
    end
  end)

  self.lovernet:addOp(libs.net.op.get_new_updates)
  self.lovernet:addValidateOnServer(libs.net.op.get_new_updates,{u='number'})
  self.lovernet:addProcessOnServer(libs.net.op.get_new_updates,function(self,peer,arg,storage)

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

  self.lovernet:addOp(libs.net.op.get_new_bullets)
  self.lovernet:addValidateOnServer(libs.net.op.get_new_bullets,{b='number'})
  self.lovernet:addProcessOnServer(libs.net.op.get_new_bullets,function(self,peer,arg,storage)

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

  self.lovernet:addOp(libs.net.op.get_resources)
  self.lovernet:addProcessOnServer(libs.net.op.get_resources,function(self,peer,arg,storage)
    local user = self:getUser(peer)
    local res = {}
    for _,restype in pairs(libs.net.resourceTypes) do
      res[restype] = math.floor(user.resources[restype])
    end
    return res
  end)

  self.lovernet:addOp(libs.net.op.get_points)
  self.lovernet:addProcessOnServer(libs.net.op.get_points,function(self,peer,arg,storage)
    local user = self:getUser(peer)
    return user.points
  end)

  self.lovernet:addOp(libs.net.op.action)
  self.lovernet:addValidateOnServer(libs.net.op.action,{
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
  self.lovernet:addProcessOnServer(libs.net.op.action,function(self,peer,arg,storage)
    local user = self:getUser(peer)
    for _,object_id in pairs(arg.t) do
      local parent = server:findObject(object_id,storage)
      libs.net.build(server,user,parent,arg.a)
    end
  end)

  self.lovernet:addOp(libs.net.op.time)
  self.lovernet:addProcessOnServer(libs.net.op.time,function(self,peer,arg,storage)
    return love.timer.getTime()
  end)

  self.lovernet:addOp(libs.net.op.get_chat)
  self.lovernet:addValidateOnServer(libs.net.op.get_chat,{i='number'})
  self.lovernet:addProcessOnServer(libs.net.op.get_chat,function(self,peer,arg,storage)
    local chats = {}
    for _,chat in pairs(storage.chats) do
      if chat.index > arg.i then
        table.insert(chats,{
          i=chat.index,
          u=chat.user,
          t=chat.text,
        })
      end
    end
    return chats
  end)

  -- todo: add UTF8 check
  self.lovernet:addOp(libs.net.op.add_chat)
  self.lovernet:addValidateOnServer(libs.net.op.add_chat,{t='string'})
  self.lovernet:addProcessOnServer(libs.net.op.add_chat,function(self,peer,arg,storage)
    local user = self:getUser(peer)
    storage.global_chat_index = storage.global_chat_index + 1
    table.insert(storage.chats,{
      index=storage.global_chat_index,
      user=user.id,
      text=arg.t,
    })
  end)

  server:resetGame()

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

    local storage = lovernet_scope.lovernet:getStorage()
    if storage.config.game_started then
      user.not_playing = true
    end

  end)

  self.lovernet:onRemoveUser(function(user)
    for _,object in pairs(self.lovernet:getStorage().objects) do
      if libs.net.userOwnsObject(user,object) then
        server:addUpdate(object,{remove=true},"delete_objects")
        object.remove = true
      end
    end
  end)

  server.setupActions(self.lovernet:getStorage())

  server.run_localhost = false

end

function server:leave()
  self.lovernet:disconnect()
end

function server:resetGame()

  print('Server resetting game')

  self._addUpdateProfile = {}

  if self.lovernet:getStorage().config then
    for ai_id = 1,self.lovernet:getStorage().config.ai do
      self.lovernet:_removeUser("ai_"..ai_id)
    end
    self.lovernet:getStorage().ai_are_connected = nil
  end

  self.lovernet:getStorage().config = {
    git_hash = git_hash,
    git_count = git_count,
    game_start=false,
    preset=#libs.mppresets.getPresets(),
    points=1,
    transmitRate=1,
    creative=false,
    everyShipUnlocked=false,
    ai=0,
  }

  local ai_players = self.lovernet:getStorage().ai_players
  if ai_players then
    for _,ai_player in pairs(ai_players) do
      ai_players.config = nil
    end
  end
  self.lovernet:getStorage().ai_players = {}

  local players = self.lovernet:getStorage().players
  if players then
    for _,player in pairs(players) do
      player.config = nil
    end
  end
  self.lovernet:getStorage().players = {}

  self.lovernet:getStorage().objects = {}
  self.lovernet:getStorage().objects_index = 0

  self.lovernet:getStorage().updates = {}
  self.lovernet:getStorage().global_update_index = 0

  self.lovernet:getStorage().bullets = {}
  self.lovernet:getStorage().global_bullet_index = 0

  self.lovernet:getStorage().chats = {}
  self.lovernet:getStorage().global_chat_index = 0

  self.last_user_index = 0

  self.lovernet:getStorage().world = libs.bump.newWorld(server._bump_cell_size)

end

function server:newGame()

  print('Server starting new game')

  local maptype = "spacedpockets"
  local pockets = self.maps[maptype].generate(
    self.lovernet:getStorage(),
    server.maps.spacedpockets.config)

  if self.lovernet:getStorage().config.ai then
    local ai_players = self.lovernet:getStorage().ai_players
    for ai_index = 1,self.lovernet:getStorage().config.ai do
      local ai = ai_players[ai_index]
      local peer = "ai_"..ai.config.ai
      self.lovernet:_addUser(peer)
      local user = self.lovernet:getUser(peer)
      user.config = ai.config
      user.ai = libs.ai.new{
        user = user,
        pockets = pockets,
        storage = self.lovernet:getStorage(),
        server = server,
      }
    end
  end
  self.lovernet:getStorage().ai_are_connected = true

  if headless then
    libs.researchrenderer.load(false,self.lovernet:getStorage().config.preset)
  end

  local user_count = 0
  local researchableObjects
  for peer,user in pairs(self.lovernet:getUsers()) do
    -- todo: add unique names
    user_count = user_count + 1
    self.generatePlayer(self.lovernet:getStorage(),user,pockets[user_count])
    if user.ai then
      -- todo: balance players on pockets after 8
      user.ai:setCurrentPocket(pockets[user_count])
      user.ai:setPockets(pockets)
    end
    local storage = self.lovernet:getStorage()
    if storage.config.everyShipUnlocked then
      local preset_value = storage.config.preset
      local preset = libs.mppresets.getPresets()[preset_value]
      researchableObjects = researchableObjects or libs.researchrenderer.getResearchableObjects(nil,preset.gen.first)
      for _,researchableObject in pairs(researchableObjects) do
        libs.researchrenderer.setUnlocked(user,researchableObject.type)
      end
    end
  end

end

-- TARGET IS

function server:targetIsSelf(object,target)
  return object.index == target.index
end

function server:targetIsAlly(object,target)
  return self:objectsAreAllies(object,target)
end

function server:targetIsEnemy(object,target)
  return target.user ~= nil and not self:objectsAreAllies(object,target)
end

function server:targetCanBeShot(object)
  return object.health ~= nil
end

function server:targetIsNeutral(object,target)
  return target.user == nil
end

function server:targetIsInShootRange(object,target)
  local object_type = libs.objectrenderer.getType(object.type)
  local tdistance = object_type.shoot and object_type.shoot.range or 0--math.huge
  return libs.net.distance(object,target,love.timer.getTime()) < tdistance
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
      },"gotoTarget")
    end
  else
    self:stopUpdateObject(object)
  end
end

function server:shootTarget(object,target,dt)
  local distance = libs.net.distance(object,target,love.timer.getTime())
  local object_type = libs.objectrenderer.getType(object.type)
  if distance <= object_type.shoot.range then
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
        eta=distance/object_type.shoot.speed,
        type=object.type,
      })
    end
  end
end

function server:repairTarget(config,object,target,dt)
  local distance = libs.net.distance(object,target,love.timer.getTime())
  local object_type = libs.objectrenderer.getType(object.type)
  local target_type = libs.objectrenderer.getType(target.type)
  if target_type.health and distance <= server:getFollowRange(object,target) then
    local restype = "material"
    local amount_to_repair = object_type.repair*dt
    local max_repair = target_type.health.max - target.health
    if amount_to_repair > max_repair then
      amount_to_repair = max_repair
    end
    local user = server:getUserById(object.user)
    if user and not config.creative then
      if amount_to_repair > user.resources[restype] then
        amount_to_repair = user.resources[restype]
      end
    end
    if amount_to_repair > 0 then
      target.health = target.health+amount_to_repair
      self:addUpdate(target,{
        health_repair=target.health,
      },"repairTarget")
      if user and not config.creative then
        self:changeResource(user,restype,-amount_to_repair)
      end
      server:addGather(dt,object,amount_to_repair)
    end
  end
end

function server:takeoverTarget(object,target)
  local distance = libs.net.distance(object,target,love.timer.getTime())
  local target_type = libs.objectrenderer.getType(target.type)
  local valid_allegiance = target.user == nil or not self:objectsAreAllies(object,target)
  if target_type.health and valid_allegiance and distance < server:getFollowRange(object,target) then
    target.user = object.user
    self:addUpdate(target,{
      user=target.user,
    },"takeoverTarget:target")
    object.health = 0
    self:addUpdate(object,{health=0,},"takeoverTarget:source")
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

function server:getUserById(id)
  if id == nil then return end
  for _,user in pairs(self.lovernet:getUsers()) do
    if user.id == id then
      return user
    end
  end
end

function server:objectsAreAllies(obj1,obj2)
  local user1 = self:getUserById(obj1.user)
  local user2 = self:getUserById(obj2.user)
  if user1 and user2 then
    return user1.config.team == user2.config.team
  else
    if user1 == nil then
      print("server:objectsAreAllies(obj1,obj2):user1==nil")
    end
    if user2 == nil then
      print("server:objectsAreAllies(obj1,obj2):user2==nil")
    end
  end
  return true
end

function server:objectIsAlly(user1,obj)
  local user2 = self:getUserById(obj.user)
  if user1 and user2 then
    return user1.config.team == user2.config.team
  else
    if user1 == nil then
      print("server:objectIsAlly(user1,obj):user1==nil")
    end
    if user2 == nil then
      print("server:objectIsAlly(user1,obj):user2==nil")
    end
  end
end

function server:changeResource(user,restype,amount)
  user.resources[restype] = user.resources[restype] + amount
  local cargo = user.cargo[restype]
  local value = user.resources[restype]
  user.resources[restype] = math.min(math.max(value,0),cargo)
end

function server:attackNearby(object,world)
  if object.user ~= nil and not libs.net.hasTarget(object) then
    assert(object.target==nil)
    local object_type = libs.objectrenderer.getType(object.type)
    if object_type.shoot then
      local storage = self.lovernet:getStorage()
      local nearby = {}

      local cx,cy = libs.net.getCurrentLocation(object)
      local items, len = world:queryPoint(cx,cy)

      for _,tobject in pairs(items) do
        if tobject.index ~= object.index and tobject.user ~= nil and not self:objectsAreAllies(tobject,object) then
          if libs.net.distance(object,tobject,love.timer.getTime()) < object_type.shoot.aggression then
            table.insert(nearby,tobject)
          end
        end
      end

      local tobject = nearby[math.random(#nearby)]
      if tobject then
        assert(tobject.index~=nil)
        assert(object.target==nil)
        object.target = tobject.index
        server:addUpdate(object,{
          target = object.target,
        },"attackNearby")
        return
      end

    end
  end
end

function server:collectNearby(object,world)
  if object.user ~= nil and not libs.net.hasTarget(object) then
    assert(object.target==nil)
    local object_type = libs.objectrenderer.getType(object.type)
    if object_type.collect ~= nil then
      local storage = self.lovernet:getStorage()
      local nearby = {}

      local cx,cy = libs.net.getCurrentLocation(object)
      local items, len = world:queryPoint(cx,cy)

      for _,tobject in pairs(items) do

        local tobject_type = libs.objectrenderer.getType(tobject.type)

        for _,restype in pairs(libs.net.resourceTypes) do
          local gather_str = restype.."_gather"
          local supply_str = restype.."_supply"
          local user = self:getUserById(object.user)
          if user then
            local has_space = user.cargo[restype] > user.resources[restype]
            local types_match = object_type[gather_str] and tobject_type[supply_str]
            if has_space and types_match and libs.net.distance(object,tobject,love.timer.getTime()) < object_type.fow*1024 then
              table.insert(nearby,tobject)
            end
          end
        end

      end

      local tobject = nearby[math.random(#nearby)]
      if tobject then
        assert(tobject.index~=nil)
        assert(object.target==nil)
        object.target = tobject.index
        server:addUpdate(object,{
          target = object.target,
        },"collectNearby")
        return
      end

    end
  end
end

function server:explodeNearby(object,world)
  local object_type = libs.objectrenderer.getType(object.type)
  if object_type.explode then

    local storage = self.lovernet:getStorage()
    local explode = false
    local nearby = {}

    local cx,cy = libs.net.getCurrentLocation(object)
    local items, len = world:queryPoint(cx,cy)

    for _,tobject in pairs(items) do
      if tobject.health then

        local distance = libs.net.distance(object,tobject,love.timer.getTime())
        if distance <= object_type.explode.damage_range then
          table.insert(nearby,tobject)
          if not self:objectsAreAllies(tobject,object) and distance <= object_type.explode.range then
            explode = true
          end
        end

      end
    end

    if explode then
      object.health = 0
      self:addUpdate(object,{health=0,},"explodeNearby:source")
      for _,tobject in pairs(nearby) do
        tobject.health = math.max(0,tobject.health - object_type.explode.damage)
        self:addUpdate(tobject,{
          health=tobject.health,
        },"explodeNearby:target")
      end
    end

  end
end

function server:validateConfig()
  local storage = self.lovernet:getStorage()
  storage.config.ai = math.max(0,storage.config.ai)
  local user_count = 0
  for _,_ in pairs(self.lovernet:getUsers()) do
    user_count = user_count + 1
  end
  storage.config.ai = math.min(server.maxPlayers-user_count,storage.config.ai)
  if storage.config.preset > #libs.mppresets.getPresets() then
    storage.config.preset = 1
  end
  if storage.config.points > #libs.net.points then
    storage.config.points = 1
  end
  if storage.config.transmitRate > #libs.net.transmitRates then
    storage.config.transmitRate = 1
  end
  local tr_val = libs.net.transmitRates[storage.config.transmitRate].value
  self.lovernet:setClientTransmitRate(tr_val)
end

function server:validatePlayerConfig(player)
  if player.team > server.maxPlayers then
    player.team = 1
  end
  if player.diff and player.diff > #libs.net.aiDifficulty then
    player.diff = 1
  end
  local all_ready = true
  for _,user in pairs(self.lovernet:getUsers()) do
    if user.config == nil or user.config.ready ~= true then
      all_ready = false
      break
    end
  end
  self.lovernet:getStorage().config.game_start = all_ready
end

function server:update(dt)
  self.lovernet:update(dt)
  local storage = self.lovernet:getStorage()

  for _,object in pairs(storage.objects) do
    local object_type = libs.objectrenderer.getType(object.type)
    if object_type.speed then
      local size = (object_type.fow or 1)*1024
      local x,y = libs.net.getCurrentLocation(object)
      storage.world:update(object,x-size/2,y-size/2)
    end
  end

  if storage.config.game_started then
    if not libs.net.hasUserObjects(storage.objects) then
      server:resetGame()
    end
  else
    self:validateConfig()
    for _,user in pairs(self.lovernet:getUsers()) do
      if user.config then
        self:validatePlayerConfig(user.config)
      end
    end
    if storage.config.game_start then
      storage.config.game_started = true
      server:newGame()
    end
  end

  for peer,user in pairs(self.lovernet:getUsers()) do
    if user.ai then
      user.ai:update(dt)
    end
  end

  for object_index,object in pairs(storage.objects) do

    local object_type = libs.objectrenderer.getType(object.type)
    if object_type.shoot and object_type.shoot.reload then
      object.reload_dt = (object.reload_dt or 0) + dt
    end

    local user = self:getUserById(object.user)
    local target = self:findObject(object.target)

    if object.build_queue then
      object.build_queue.dt = object.build_queue.dt - dt
      if object.build_queue.dt <= 0 then
        object.build_queue.onDone()
        object.build_queue = nil
      end
    end

    if target == nil then
      object.target = nil
    end

    self:collectNearby(object,storage.world)
    self:attackNearby(object,storage.world)
    self:explodeNearby(object,storage.world)

    if user then

      for _,restype in pairs(libs.net.resourceTypes) do

        local gen_str = restype.."_generate"
        if object_type[gen_str] then
          local amount = object_type[gen_str]*dt
          local space_remaining = user.cargo[restype] - user.resources[restype]
          if amount > space_remaining then
            amount = space_remaining
          end
          self:changeResource(user,restype,amount)
          server:addGather(dt,object,amount)
        end

        local convert_str = restype.."_convert"
        if object_type[convert_str] then
          local trestype = object_type[convert_str].output
          local amount = object_type[convert_str].rate*dt
          local space_remaining = user.cargo[trestype] - user.resources[trestype]
          if amount > space_remaining then
            amount = space_remaining
          end
          if amount > user.resources[restype] then
            amount = user.resources[restype]
          end
          user.resources[restype] = user.resources[restype] - amount
          user.resources[trestype] = user.resources[trestype] + amount
          server:addGather(dt,object,amount)
        end

      end

    end -- end user

    if target then

      local target_type = libs.objectrenderer.getType(target.type)

      if object_type.speed then

        if self:targetIsNeutral(object,target) then
          if object_type.takeover then
            self:gotoTarget(object,target,server:getFollowRange(object,target))
            self:takeoverTarget(object,target)
          else
            self:gotoTarget(object,target,server:getGatherRange(object,target))
          end
        elseif self:targetIsSelf(object,target) then
          self:stopUpdateObject(object)
        elseif self:targetIsAlly(object,target) then
          self:gotoTarget(object,target,server:getFollowRange(object,target))
          if object_type.repair then
            self:repairTarget(storage.config,object,target,dt)
          end
        elseif self:targetIsEnemy(object,target) then
          if self:targetCanBeShot(object) and object_type.shoot then
            self:gotoTarget(object,target,server:getShootRange(object,target))
            self:shootTarget(object,target,dt)
          else
            self:gotoTarget(object,target,server:getFollowRange(object,target))
            if object_type.takeover then
              self:takeoverTarget(object,target)
            end
          end
        end

      else -- not object_type.speed

        if self:targetIsEnemy(object,target) and self:targetIsInShootRange(object,target) then
          self:shootTarget(object,target,dt)
        else
          self:stopUpdateObject(object)
          self:stopUpdateObjectTarget(object)
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
              server:addGather(dt,object,amount)
              if target[supply_str] == 0 then
                local update = {}
                update[supply_str] = 0
                server:addUpdate(target,update,"<restype>_[gather|supply]")
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
      storage.world:remove(object)
      if user then
        local object_type = libs.objectrenderer.getType(object.type)
        user.count = user.count - 1
        user.points = (user.points or 0) - (object_type.points or 1)
        assert(user.count>=0)
        self.updateCargo(storage,user)
        local cx,cy = libs.net.getCurrentLocation(object,love.timer.getTime())
        if object_type.cost and object_type.cost.material then
          local debris = server.createObject(storage,"debris",cx,cy,nil)
          debris.material_supply = object_type.cost.material*server._debris_ratio
        end

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
        if target.health then
          target.health = math.max(0,target.health - object_type.shoot.damage)
          self:addUpdate(target,{
            health=target.health,
          },"bullet damage")
        else
          print('Warning: bullet[type='..(bullet.bullet.type)..'] cannot damage target[type='..target.type..'] as target does not have health.')
        end
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
  str = str .. "transmit_rate: " .. (self.lovernet:getClientTransmitRate()*1000) .. "ms\n"
  str = str .. "time: " .. math.floor(love.timer.getTime()) .. "\n"
  str = str .. "objects: " .. #self.lovernet:getStorage().objects .. "\n"
  str = str .. "updates: " .. #self.lovernet:getStorage().updates .. "\n"
  str = str .. "global_update_index: " .. self.lovernet:getStorage().global_update_index .. "\n"
  str = str .. "bullets: " .. #self.lovernet:getStorage().bullets .. "\n"
  str = str .. "global_bullet_index: " .. self.lovernet:getStorage().global_bullet_index .. "\n"
  for i,v in pairs(self.lovernet:getUsers()) do
    str = str .. "user["..v.name.."]: " .. v.last_update .. "\n"
  end
  str = str .. "\n"
  for i,v in pairs(server._addUpdateProfile) do
    str = str .. i .. " - " .. v .. "\n"
  end

  love.graphics.printf(str,32,32,love.graphics.getWidth()-64,"left")
  libs.version.draw()
end

return server
