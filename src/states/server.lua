local server = {}

-- update system will spam network if this is <=1
server._follow_update_mult = 1.2
server._shoot_update_mult = 0.8
server._gather_update_mult = 0.5

server._gather_refresh = 2

server._throttle_object_updates = math.huge
server._throttle_bullet_updates = math.huge

server._debris_ratio = 0.5

server._genEveryObjectOverride = false

server._genResourcesDefault = {
  material = math.huge,
  crew = math.huge,
}

server._maxUserUnits = math.huge

server._bump_cell_size = 64

function server.setupActions(storage)

  server.actions = {}

  for _,object_type in pairs(libs.objectrenderer.getTypes()) do
    local action = "build_"..object_type.type
    server.actions[action] = function(user,parent)

      -- lazy init to prevent tons of extra tables

      if parent.build_queue == nil and server.objectCanAfford(object_type,user,storage) then
        local build_time = storage.config.creative and 0.1 or object_type.build_time
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
      else
        server:addUpdate(parent,{
          dequeue=true,
        },"setupActions dequeue")
      end

    end
  end

end

server.maps = {}

server.maps.spacedpockets = {
  config = {
    attemptRatio = 10,
    size = 1024/2,
    range = 1024*2,
  },
}

function server.maps.spacedpockets.generate(storage,config)

  local mapsize = libs.net.mapSizes[storage.config.mapsize].value
  local mapGenDefault = libs.net.mapGenDefaults[storage.config.mapGenDefault].value

  local pocketAttempt = 0

  local newPocket = function()
    local x = math.random(-mapsize+config.size,mapsize-config.size)
    local y = math.random(-mapsize+config.size,mapsize-config.size)
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
  while #pockets < storage.config.mapPockets do
    local pocket = newPocket()
    if validPocket(pockets,pocket) then
      table.insert(pockets,pocket)
    end
    pocketAttempt = pocketAttempt + 1
  end

  -- print("pocket creation attempts:"..tostring(pocketAttempt))

  for object_type,object_count in pairs(mapGenDefault) do
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

server.maps.random = {
  config = {
    distribution = 1,
  },
}

function server.maps.random.generate(storage,config)

  local mapsize = libs.net.mapSizes[storage.config.mapsize].value
  local mapGenDefault = libs.net.mapGenDefaults[storage.config.mapGenDefault].value

  local pockets = {}
  for x = -config.distribution,config.distribution do
    for y = -config.distribution,config.distribution do
      table.insert(pockets,{
        x=mapsize*x/(config.distribution+0.5),
        y=mapsize*y/(config.distribution+0.5),
      })
    end
  end

  -- shuffle
  for i = #pockets, 2, -1 do
    local j = math.random( 1, i );
    pockets[i], pockets[j] = pockets[j], pockets[i];
  end

  for object_type,object_count in pairs(mapGenDefault) do
    for i = 1,object_count do
      local x = math.random(-mapsize,mapsize)
      local y = math.random(-mapsize,mapsize)
      server.createObject(storage,object_type,x,y,nil)
    end
  end

  return pockets

end

server.maps.training = {}

function server.maps.training.generate(storage,config)

  local mapsize = libs.net.mapSizes[storage.config.mapsize].value
  local mapGenDefault = libs.net.mapGenDefaults[storage.config.mapGenDefault].value

  local pockets = {
    {x=0,y=0},
    {x=0,y=0}, -- wtf this is probably a bug
  }

  for object_type,object_count in pairs(mapGenDefault) do
    for i = 1,object_count do
      local t = math.pi*2*math.random()
      local r = mapsize+math.random(-512,512)-512-256
      local x = r*math.cos(t)
      local y = r*math.sin(t)
      server.createObject(storage,object_type,x,y,nil)
    end
  end

  return pockets
end

function server.generatePlayer(storage,user,pocket,gen)

  if gen == libs.levelshared.gen.none then
    return
  end

  local mapsize = libs.net.mapSizes[storage.config.mapsize].value

  local x,y
  if pocket then
    local t = math.random()*math.pi*2
    x = pocket.x + math.cos(t)*mapsize/4
    y = pocket.y + math.sin(t)*mapsize/4
  else
    x = math.random(-mapsize,mapsize)
    y = math.random(-mapsize,mapsize)
  end
  local gen_render = user.config.race_gen
  if gen_render.first then
    server.createObject(storage,gen_render.first,x,y,user)
  end

  local genlist = gen_render.default
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
  -- for _,object in pairs(storage.objects) do

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

  -- end
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

function server:findObject(index)
  if index == nil then return end
  return libs.net.findObject(self.lovernet:getStorage().objects,index)
end

function server:findObjectsOfType(type)
  local objects = {}
  for _,object in pairs(self.lovernet:getStorage().objects) do
    if object.type == type then
      table.insert(objects,object)
    end
  end
  return objects
end

function server:generatePlayers(users,storage)
  local players = {}
  for index_player,real_player in pairs(users) do
    real_player.config = real_player.config or {
      id=real_player.id,
      team=#players+1,
      race=1,
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
          race=2,
        }
      }
      table.insert(players,storage.ai_players[ai_index].config)
    end
  end
  return players
end

function server.addChat(storage,user,text)
  storage.global_chat_index = storage.global_chat_index + 1
  table.insert(storage.chats,{
    index=storage.global_chat_index,
    user=user.id,
    text=text,
  })
end

function server:init()
  self.lovernet = nil

  local enet
  if game_singleplayer then
    enet=require"libs.enetfake"
  else
    enet=require"enet"
  end

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
      enet=enet,
      port=settings:read("server_port"),
    }
    if game_singleplayer then
      self.lovernet._encode = deencode
      self.lovernet._decode = deencode
    end
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
    local user = self:getUser(peer)
    if user.config_dirty then
      user.config_dirty = nil
      return storage.config
    end
  end)

  self.lovernet:addOp(libs.net.op.get_level)
  self.lovernet:addProcessOnServer(libs.net.op.get_level,function(self,peer,arg,storage)
    return storage.level
  end)

  self.lovernet:addOp(libs.net.op.set_config)
  self.lovernet:addValidateOnServer(libs.net.op.set_config,{d='table'})
  self.lovernet:addProcessOnServer(libs.net.op.set_config,function(self,peer,arg,storage)
    for _,user in pairs(self:getUsers()) do
      user.config_dirty = true
    end
    for i,v in pairs(arg.d) do
      storage.config[i] = v ~= "nil" and v or nil
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
      local parent = server:findObject(object_id)
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
    server.addChat(storage,user,arg.t)
  end)

  server:resetGame()

  local lovernet_scope = self

  self.lovernet:onAddUser(function(user)

    user.config_dirty = true
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
  if self.lovernet then
    self.lovernet:disconnect()
  end
end

function server:resetGame()

  print('Server resetting game')

  self._addUpdateProfile = {}

  local storage = self.lovernet:getStorage()

  if storage.config then
    for ai_id = 1,storage.config.ai do
      self.lovernet:_removeUser("ai_"..ai_id)
    end
    storage.ai_are_connected = nil
  end
  if storage.ai_players then
    for _,ai_player in pairs(storage.ai_players) do
      ai_player.config = nil
    end
  end
  storage.ai_players = {}

  storage.config = {
    git_hash = git_hash,
    git_count = git_count,
    game_start=false,
    preset=#libs.mppresets.getPresets(),
    points=1,
    map=1,
    mapsize=1,
    mapGenDefault=1,
    mapPockets=8,
    transmitRate=1,
    levelSelect=1,
    creative=false,
    everyShipUnlocked=false,
    ai=1,
  }

  storage.objects = {}
  storage.objects_index = 0

  storage.updates = {}
  storage.global_update_index = 0

  storage.bullets = {}
  storage.global_bullet_index = 0

  storage.chats = {}
  storage.global_chat_index = 0

  self.last_user_index = 0

  storage.world = libs.bump.newWorld(server._bump_cell_size)

  self._public_t = 10
  self._public_dt = self._public_t

end

function server:newGame(soft)

  print('Server starting new game ('..(soft and "soft" or "hard")..')')

  local storage = self.lovernet:getStorage()
  if not soft then
    storage.gamemode = libs.mpgamemodes.new()
    local gamemode_object = storage.gamemode:getGamemodeById(storage.config.gamemode)
    storage.gamemode:setCurrentGamemode(gamemode_object)
    storage.gamemode:loadCurrentLevel()
    storage.level = {
      id=storage.gamemode:getCurrentLevelData().id,
    }
  end

  local level = storage.gamemode:getCurrentLevelData()

  local maptype = level.map or libs.net.maps[storage.config.map].value
  local pockets = self.maps[maptype].generate(
    storage,
    server.maps[maptype].config)

  -- todo: This is a hack - we should actually be checking the server object
  g_pockets = pockets

  if level.players_skel then
    for _,user in pairs(self.lovernet:getUsers()) do
      if not user.ai then
        for i,v in pairs(level.players_skel) do
          user[i] = v
        end
      end
    end
  end

  if level.players_config_skel then
    for _,user in pairs(self.lovernet:getUsers()) do
      if not user.ai then
        for i,v in pairs(level.players_config_skel) do
          user.config[i] = v
        end
      end
    end
  end

  if level.ai_players then
    absorb(storage.ai_players,level.ai_players)
    storage.config.ai = #level.ai_players
  end

  -- todo: clean this up so we can change the number of AI in a gamemode
  if not soft then
    if storage.config.ai then
      for ai_index = 1,storage.config.ai do
        local ai = storage.ai_players[ai_index]
        local peer = "ai_"..ai.config.ai
        self.lovernet:_addUser(peer)
        local user = self.lovernet:getUser(peer)
        user.config = ai.config
        user.ai = libs.ai.new{
          user = user,
          pockets = pockets,
          storage = storage,
          server = server,
        }
      end
    end
    storage.ai_are_connected = true
  end

  local preset_value = storage.config.preset
  local preset = libs.mppresets.getPresets()[preset_value]

  local user_count = 0
  for peer,user in pairs(self.lovernet:getUsers()) do

    if user.config.race then
      user.config.race_gen = libs.levelshared.gen[libs.net.race[user.config.race].gen]()
    end

    local gen = user.gen
    -- todo: add unique names
    user_count = user_count + 1
    if user.ai then
      -- todo: balance players on pockets after 8
      user.ai:setCurrentPocket(pockets[user_count])
      user.ai:setPockets(pockets)
      -- this is a hack, fix it later
      if level.ai_players then
        local current_ai_player = storage.ai_players[user.config.ai]
        user.ai:setDiff(current_ai_player.config.diff)
        gen = current_ai_player.gen or gen
      end
    end
    self.generatePlayer(storage,user,pockets[user_count],gen)
  end

  if headless then
    libs.researchrenderer.load(false,storage.config.preset)
  end

  if not soft and storage.config.everyShipUnlocked then
    for peer,user in pairs(self.lovernet:getUsers()) do
      local race_gen = user.config.race_gen
      local researchableObjects = libs.researchrenderer.getResearchableObjects(nil,race_gen.first)
      for _,researchableObject in pairs(researchableObjects) do
        libs.researchrenderer.setUnlocked(user,researchableObject.type)
      end
    end
  end

  if level.init then
    level:init(self)
  end

end

function server:nextLevel(next_level)
  local storage = self.lovernet:getStorage()
  storage.level = {id=next_level}
  storage.gamemode:setCurrentLevel(next_level)
  storage.gamemode:loadCurrentLevel()

  -- clear current level
  for _,object in pairs(storage.objects) do
    object.remove_no_drop = true
    object.remove = true
    server:addUpdate(object,{remove=true},"delete_objects")
  end

  -- load new game
  self:newGame(true)

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

function server:targetCanBeShot(object_type)
  return object_type.health ~= nil
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

function server:jumpTarget(config,object,target,dt)
  if config.jump == nil then
    local distance = libs.net.distance(object,target,love.timer.getTime())
    if distance <= server:getFollowRange(object,target) then
      for _,user in pairs(self.lovernet:getUsers()) do
        user.config_dirty = true
      end
      config.jump = {
        start = math.floor(love.timer.getTime()),
        t = 30,
      }
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
          local tobject_type = libs.objectrenderer.getType(tobject.type)
          if self:targetCanBeShot(tobject_type) and libs.net.distance(object,tobject,love.timer.getTime()) < object_type.shoot.aggression then
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
        self:dealDamage(tobject,object_type.explode.damage)
      end
    end

  end
end

function server:dealDamage(object,raw_damage)
  local damage
  if object.damage_reduction then
    damage = raw_damage*object.damage_reduction
    -- print('using damage reduction: '..raw_damage.." => "..damage)
  else
    damage = raw_damage
  end
  object.health = math.max(0,object.health - damage)
  self:addUpdate(object,{
    health=object.health,
  },"dealDamge")
end

function server:getPlayerCount()
  local storage = self.lovernet:getStorage()
  local user_count = 0
  for _,_ in pairs(self.lovernet:getUsers()) do
    user_count = user_count + 1
  end
  return user_count + storage.config.ai,user_count
end

function server:validateConfig()
  local storage = self.lovernet:getStorage()
  local player_count,user_count = self:getPlayerCount()
  storage.config.ai = math.max(0,storage.config.ai)
  storage.config.ai = math.min(libs.net.max_players-user_count,storage.config.ai)
  if storage.config.preset > #libs.mppresets.getPresets() then
    storage.config.preset = 1
  end
  if storage.config.preset < 1 then
    storage.config.preset = #libs.mppresets.getPresets()
  end
  if storage.config.points > #libs.net.points then
    storage.config.points = 1
  end
  if storage.config.points < 1 then
    storage.config.points = #libs.net.points
  end
  if storage.config.map > #libs.net.maps then
    storage.config.map = 1
  end
  if storage.config.map < 1 then
    storage.config.map = #libs.net.maps
  end
  if storage.config.mapsize > #libs.net.mapSizes then
    storage.config.mapsize = 1
  end
  if storage.config.mapsize < 1 then
    storage.config.mapsize = #libs.net.mapSizes
  end
  if storage.config.mapGenDefault > #libs.net.mapGenDefaults then
    storage.config.mapGenDefault = 1
  end
  if storage.config.mapGenDefault < 1 then
    storage.config.mapGenDefault = #libs.net.mapGenDefaults
  end
  if storage.config.mapPockets > 16 then
    storage.config.mapPockets = 1
  end
  if storage.config.mapPockets < player_count then
    storage.config.mapPockets = 16
  end
  if storage.config.transmitRate > #libs.net.transmitRates then
    storage.config.transmitRate = 1
  end
  if storage.config.transmitRate < 1 then
    storage.config.transmitRate = #libs.net.transmitRates
  end
  local tr_val = libs.net.transmitRates[storage.config.transmitRate].value
  self.lovernet:setClientTransmitRate(tr_val)

  -- todo: add levelSelect check

  -- gamemode overrides
  if storage.config.gamemode then
    local gamemode = libs.mpgamemodes:getGamemodeById(storage.config.gamemode)
    if gamemode.map_size then
      storage.config.mapsize = gamemode.map_size
    end
    if gamemode.every_ship_unlocked then
      storage.config.everyShipUnlocked = gamemode.every_ship_unlocked
    end
  end

end

function server:validatePlayerConfig(player)

  local player_count = self:getPlayerCount()
  if player.team > player_count then
    player.team = 1
  end
  if player.race then
    if player.race > #libs.net.race then
      player.race = 1
    end
    if player.race < 1 then
      player.race = #libs.net.race
    end
  end
  if player.diff then
    if player.diff > #libs.net.aiDifficulty then
      player.diff = 1
    end
    if player.diff < 1 then
      player.diff = #libs.net.aiDifficulty
    end
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
    -- todo: figure out6 how to clean this up without it breaking things
    -- see https://github.com/josefnpat/roguecraft-squadron/issues/665
    --[[
    if not libs.net.hasUserObjects(storage.objects) then
      server:resetGame()
    end
    --]]
    if settings:read("server_public") and storage.config.game_started_trigger == nil then
      storage.config.game_started_trigger = true
      libs.mpserverlist.sendPublicUpdate(true,self:getPlayerCount())
    end
  else
    if settings:read("server_public") then
      self._public_dt = self._public_dt + dt
      if self._public_dt > self._public_t then
        self._public_dt = 0
        libs.mpserverlist.sendPublicUpdate(false,self:getPlayerCount())
      end
    end

    self:validateConfig()
    for _,user in pairs(self.lovernet:getUsers()) do
      if user.config then
        self:validatePlayerConfig(user.config)
      end
    end
    if storage.config.game_start then
      storage.config.game_started = true
      for _,user in pairs(self.lovernet:getUsers()) do
        user.config_dirty = true
      end
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
          elseif target_type.jump then
            self:jumpTarget(storage.config,object,target,dt)
          end
        elseif self:targetIsEnemy(object,target) then
          if self:targetCanBeShot(target_type) and object_type.shoot then
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
        if object.drop_debris ~= false and object.remove_no_drop == nil then
          local cx,cy = libs.net.getCurrentLocation(object,love.timer.getTime())
          if object_type.cost and object_type.cost.material then
            local debris = server.createObject(storage,"debris",cx,cy,nil)
            debris.material_supply = object_type.cost.material*server._debris_ratio
          end
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
          self:dealDamage(target,object_type.shoot.damage)
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

  if storage.gamemode then
    local users = self.lovernet:getUsers()
    local players = self:generatePlayers(users,storage)
    local level = storage.gamemode:getCurrentLevelData()
    if level.update then
      level:update(dt,self)
    end
    if level.victory and level.victory(storage,players) then
      if level.next_level then
        storage.level.endt = storage.level.endt or love.timer.getTime() + libs.net.next_level_t
        if storage.level.endt <= love.timer.getTime() then
          self:nextLevel(level.next_level)
        end
      else
        --print('game over')
      end
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
