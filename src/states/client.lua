local utf8 = require"utf8"

local client = {}

function client:init()
  -- todo: i18n
  self.menu = libs.menu.new{title="[MENU]"}
  self.menu:add(libs.i18n('pause.continue'),function()
    self.menu_enabled = false
  end)
  -- todo:
  -- self.menu:add(libs.i18n('pause.options'),function()
  -- end)
  self.menu:add(libs.i18n('pause.gameover'),function()
    -- todo: disconnect the user, lolol
    libs.hump.gamestate.switch(states.menu)
    self.menu_enabled = false
  end)

  self.soundtrack = libs.soundtrack.new()

  local updateaDynamicAudio = function(da)
    if da:getTargetTrack() == 4 then
      da:setTrackFadeIn(1,6)
      da:setTrackFadeOut(1,1)
      da:setTrackFadeIn(2,6)
      da:setTrackFadeOut(2,1)
      da:setTrackFadeIn(3,6)
      da:setTrackFadeOut(3,1)
      da:setTrackFadeIn(4,1)
      da:setTrackFadeOut(4,6)
    else
      da:setTrackFadeIn(1,6)
      da:setTrackFadeOut(1,6)
      da:setTrackFadeIn(2,6)
      da:setTrackFadeOut(2,6)
      da:setTrackFadeIn(3,6)
      da:setTrackFadeOut(3,6)
      da:setTrackFadeIn(4,6)
      da:setTrackFadeOut(4,6)
    end
  end

  local da

  da = libs.dynamicaudio.new()
  da:addTrack("assets/dynamicaudio/AsteroidMining/1.ogg")
  da:addTrack("assets/dynamicaudio/AsteroidMining/2.ogg")
  da:addTrack("assets/dynamicaudio/AsteroidMining/3.ogg")
  da:addTrack("assets/dynamicaudio/AsteroidMining/4.ogg")
  self.soundtrack:addDynamicAudio(da,updateaDynamicAudio)

  da = libs.dynamicaudio.new()
  da:addTrack("assets/dynamicaudio/FinalFrontier/1.ogg")
  da:addTrack("assets/dynamicaudio/FinalFrontier/2.ogg")
  da:addTrack("assets/dynamicaudio/FinalFrontier/3.ogg")
  da:addTrack("assets/dynamicaudio/FinalFrontier/4.ogg")
  self.soundtrack:addDynamicAudio(da,updateaDynamicAudio)

  self.soundtrack:play()

end

function client:enter()

  self.lovernet = libs.lovernet.new{serdes=libs.bitser,ip=self._remote_address}
  self.lovernet:addOp(libs.net.op.git_count)
  self.lovernet:addOp(libs.net.op.user_count)
  self.lovernet:addOp(libs.net.op.get_user)
  self.lovernet:addOp(libs.net.op.get_config)
  self.lovernet:addOp(libs.net.op.set_config)
  self.lovernet:addOp(libs.net.op.set_players)
  self.lovernet:addOp(libs.net.op.get_players)
  self.lovernet:addOp(libs.net.op.set_research)
  self.lovernet:addOp(libs.net.op.get_research)
  self.lovernet:addOp(libs.net.op.debug_create_object)
  self.lovernet:addOp(libs.net.op.get_new_objects)
  self.lovernet:addOp(libs.net.op.get_new_updates)
  self.lovernet:addOp(libs.net.op.get_new_bullets)
  self.lovernet:addOp(libs.net.op.move_objects)
  self.lovernet:addOp(libs.net.op.target_objects)
  self.lovernet:addOp(libs.net.op.get_resources)
  self.lovernet:addOp(libs.net.op.get_points)
  self.lovernet:addOp(libs.net.op.time)
  self.lovernet:addOp(libs.net.op.action)
  self.lovernet:addOp(libs.net.op.delete_objects)
  self.lovernet:addOp(libs.net.op.add_chat)
  self.lovernet:addOp(libs.net.op.get_chat)

  -- init
  self.lovernet:pushData(libs.net.op.git_count)
  self.lovernet:pushData(libs.net.op.get_user)
  self.lovernet:pushData(libs.net.op.get_research)
  self.object_index = 0
  self.update_index = 0
  self.bullet_index = 0
  self.user_count = 0
  self.time = 0
  self.last_time = 0
  self.start_time = 0
  self.chat_index = 0
  self.selection = libs.selection.new{onChange=client.selectionOnChange,onChangeScope=self}
  self.buildqueue = libs.buildqueue.new{selection=self.selection}
  self.objects = {}
  self.bullets = {}
  self.menu_enabled = false
  self.focusObject = nil
  self.config = nil

  self.notif = libs.notif.new()
  self.camera = libs.hump.camera(0,0)
  self.minimap = libs.minimap.new()
  self.fow = libs.fow.new{camera=self.camera}
  self.resources = libs.resources.new{notif=self.notif}
  self.points = libs.points.new()
  self.planets = libs.planets.new{camera=self.camera}
  self.actionpanel = libs.actionpanel.new()
  self.explosions = libs.explosions.new()
  self.gather = libs.gather.new()
  self.moveanim = libs.moveanim.new()
  self.controlgroups = libs.controlgroups.new()
  self.chat = libs.chat.new()
  self.mpconnect = libs.mpconnect.new{lovernet=self.lovernet,chat=self.chat}
  self.mpresearch = libs.mpresearch.new{lovernet=self.lovernet}
  self.mpdisconnect = libs.mpdisconnect.new()
  self.gamestatus = libs.gamestatus.new()
  self.matchstats = libs.matchstats.new()

  self.soundtrack:setVolume(settings:read("music_vol"))
  self.soundtrack:play()

end

function client:leave()
  self.soundtrack:stop()
  self.soundtrack:update(0)
end

function client:selectionOnChange()
  self.actionpanel:process(self.selection,self.user,self.resources,self.buildqueue)
  local selection = self.selection:getSelected()
  local selection_is_users = false
  for _,object in pairs(selection) do
    if object.user == self.user.id then
      selection_is_users = true
    end
    object.anim = 1
  end
  if selection_is_users and #selection > 0 then
    libs.sfx.loopGroup("select")
  end
  self.buildqueue:doFullUpdate()
end

function client:getCameraOffsetX()
  return math.floor(self.camera.x-love.graphics.getWidth()/2)
end
function client:getCameraOffsetY()
  return math.floor(self.camera.y-love.graphics.getHeight()/2)
end
function client:getCameraOffset()
  return self:getCameraOffsetX(),self:getCameraOffsetY()
end

function client:getObjectByIndex(index)
  for _,v in pairs(self.objects) do
    if v.index == index then
      return v
    end
  end
end

function client:countPlayerObjects(user)
  local count = 0
  for _,object in pairs(self.objects) do
    if object.user == user then
      count = count + 1
    end
  end
  return count
end

function client:stackSide()
  -- fix tooltips before adding right side stack feature
  local cx,cy = 32,32
  self.minimap.x = cx
  self.minimap.y = cy
  cy = cy + self.minimap.size
  if self.points:panelShown() then
    self.points:setX(cx)
    self.points:setY(cy)
    cy = cy + self.points:getHeight()
  end
  self.resources.x = cx
  self.resources.y = cy
  cy = cy + self.resources:getHeight()
  if self.buildqueue:showPanel() then
    self.buildqueue:setX(cx)
    self.buildqueue:setY(cy)
    cy = cy + self.buildqueue:getHeight()
  end
  if self.actionpanel:showPanel() then
    self.actionpanel:setX(cx)
    self.actionpanel:setY(cy)
    cy = cy + self.actionpanel:getHeight()
  end
  self.selection:setX(cx)
  self.selection:setY(cy)
  cy = cy + self.selection:getHeight()

  self.chat:setX(love.graphics:getWidth() - self.chat:getWidth() - 32)
  self.chat:setY(love.graphics:getHeight() - self.chat:getHeight() - 32)
end

function client:update(dt)

  libs.loading.update(dt)

  self.soundtrack:update(dt)

  if not self.gamestatus:isStarted() then

    if not self.lovernet:hasData(libs.net.op.get_config) then
      self.lovernet:pushData(libs.net.op.get_config)
    end

    if not self.lovernet:hasData(libs.net.op.get_players) then
      self.lovernet:pushData(libs.net.op.get_players)
    end

    if self.players and self.user then
      local pid = libs.net.getPlayerId(self.players,self.user)
      if not self.players[pid].user_name then
        self.lovernet:pushData(libs.net.op.set_players,{
          p=self.players[pid].id,
          d={user_name=settings:read("user_name")},
          t="u",
        })
      end
    end

    self.start_time = self.time

  else -- not self.gamestatus:isStarted()

    if not self.lovernet:hasData(libs.net.op.get_new_objects) then
      self.lovernet:pushData(libs.net.op.get_new_objects,{i=self.object_index})
    end
    if not self.lovernet:hasData(libs.net.op.get_new_updates) then
      self.lovernet:pushData(libs.net.op.get_new_updates,{u=self.update_index})
    end
    if not self.lovernet:hasData(libs.net.op.get_new_bullets) then
      self.lovernet:pushData(libs.net.op.get_new_bullets,{b=self.bullet_index})
    end
    if not self.lovernet:hasData(libs.net.op.get_resources) then
      self.lovernet:pushData(libs.net.op.get_resources)
    end
    if not self.lovernet:hasData(libs.net.op.get_points) then
      self.lovernet:pushData(libs.net.op.get_points)
    end
  end

  if not self.lovernet:hasData(libs.net.op.user_count) then
    self.lovernet:pushData(libs.net.op.user_count)
  end
  if not self.lovernet:hasData(libs.net.op.time) then
    self.lovernet:pushData(libs.net.op.time)
  end
  if not self.lovernet:hasData(libs.net.op.get_chat) then
    self.lovernet:pushData(libs.net.op.get_chat,{i=self.chat_index})
  end

  if not self.gamestatus:isStarted() then
    if self.config and self.config.game_start then
      self.gamestatus:startGame()
    end
  end

  if self.lovernetprofiler then
    self.lovernetprofiler:update(dt)
  end
  self.lovernet:update(dt)

  if self.lovernet:getCache(libs.net.op.git_count) then
    self.server_git_count = self.lovernet:getCache(libs.net.op.git_count)
    self.lovernet:clearCache(libs.net.op.git_count)
  end

  if self.lovernet:getCache(libs.net.op.user_count) then
    self.user_count = self.lovernet:getCache(libs.net.op.user_count)
  end

  if self.lovernet:getCache(libs.net.op.get_user) then
    self.user = self.lovernet:getCache(libs.net.op.get_user)
    self.lovernet:clearCache(libs.net.op.get_user)
    self.selection:setUser(self.user.id)
    self.buildqueue:setUser(self.user.id)
    self.mpresearch:buildData(self.user)
    self.mpconnect:setUser(self.user.id)
  end

  if self.lovernet:getCache(libs.net.op.get_config) then
    self.config = self.lovernet:getCache(libs.net.op.get_config)
    self.lovernet:clearCache(libs.net.op.get_config)
  end

  if self.lovernet:getCache(libs.net.op.get_players) then
    self.players = self.lovernet:getCache(libs.net.op.get_players)
    self.lovernet:clearCache(libs.net.op.get_players)
  end

  if self.lovernet:getCache(libs.net.op.get_research) then
    self.user.research = self.lovernet:getCache(libs.net.op.get_research)
    self.mpresearch:buildData(self.user)
    self.lovernet:clearCache(libs.net.op.get_research)
  end

  if self.lovernet:getCache(libs.net.op.time) then
    self.time = self.lovernet:getCache(libs.net.op.time)
    self.last_time = self.time
    self.lovernet:clearCache(libs.net.op.time)
  else
    self.time = self.time + dt
  end

  if self.lovernet:getCache(libs.net.op.get_chat) then
    for _,msg in pairs(self.lovernet:getCache(libs.net.op.get_chat)) do
      if msg.i > self.chat_index then
        local player = libs.net.getPlayerById(self.players,msg.u)
        self.chat:addData(msg.u,msg.t,player and player.user_name or "N/A")
      end
      self.chat_index = math.max(self.chat_index,msg.i)
    end
    self.lovernet:clearCache(libs.net.op.get_chat)
  end

  if self.lovernet:getCache(libs.net.op.get_new_objects) then
    local change = false
    for _,sobject in pairs(self.lovernet:getCache(libs.net.op.get_new_objects)) do
      local object = self:getObjectByIndex(sobject.index)
      if not object then
        -- init objects:
        sobject.dx = sobject.x
        sobject.dy = sobject.y
        sobject.angle = math.random()*2*math.pi
        sobject.queue = {}
        if sobject.user == self.user.id then
          sobject.anim = 1
        end
        libs.objectrenderer.init(sobject)

        if not self.focusObject and sobject.user == self.user.id then
          self.focusObject = sobject
          self:lookAtObject(sobject)
          self.selection:setSingleSelected(sobject)
        end

        if sobject.unqueue_parent then
          local parent = self:getObjectByIndex(sobject.unqueue_parent)
          if parent then
            parent.build_current = nil
            self.buildqueue:doFullUpdate()
          else
            print('warning: parent is missing')
          end
        end

        table.insert(self.objects,sobject)
        self.object_index = math.max(self.object_index,sobject.index)
        change = true
      end
    end
    if change then
      self.resources:calcCargo(self.objects,self.user)
    end
    self.lovernet:clearCache(libs.net.op.get_new_objects)
  end

  if self.lovernet:getCache(libs.net.op.get_new_updates) then
    self.update_index = self.lovernet:getCache(libs.net.op.get_new_updates).i
    for sobject_index,sobject in pairs(self.lovernet:getCache(libs.net.op.get_new_updates).u) do
      local object = self:getObjectByIndex(sobject.i)
      if object then
        for i,v in pairs(sobject.u) do
          -- triggers
          if i == "health" and object.user == self.user.id then
            object.in_combat = 1
          end
          if i == "user" and v ~= object.user then
            object.user = v
            self.selection:onChange()
          end
          -- back to work
          if v == "nil" then
            object[i] = nil
          else
            -- exceptions
            if i == "health_repair" then
              object["health"] = v
            else
              object[i] = v
            end
          end
        end
      else
        -- print('Failed to update object#'..sobject.i.." (missing)")
      end
    end
    self.lovernet:clearCache(libs.net.op.get_new_updates)
  end

  if self.lovernet:getCache(libs.net.op.get_new_bullets) then
    self.bullet_index = self.lovernet:getCache(libs.net.op.get_new_bullets).i
    for sbullet_index,sbullet in pairs(self.lovernet:getCache(libs.net.op.get_new_bullets).b) do

      local source
      local target
      for _,object in pairs(self.objects) do
        if object.index == sbullet.b.s then
          source = object
        end
        if object.index == sbullet.b.t then
          target = object
        end
      end


      if source and target then

        local source_type = libs.objectrenderer.getType(source.type)
        local max = math.max(1,source_type.shoot.damage/10)
        for i = 1,max do
          local randx = source.dx + math.random(-source_type.size,source_type.size)
          local randy = source.dy + math.random(-source_type.size,source_type.size)

          local bullet = {
            x = randx,
            y = randy,
            cx = randx,
            cy = randy,
            dx = randx,
            dy = randy,
            target = target.index,
            tdt=sbullet.b.tdt,
            eta=sbullet.b.eta+(i-1)/max*source_type.shoot.reload,
            type=sbullet.b.type,
          }
          table.insert(self.bullets,bullet)
        end
      end

    end
    self.lovernet:clearCache(libs.net.op.get_new_bullets)
  end

  if self.lovernet:getCache(libs.net.op.get_resources) then
    self.resources:setFull(self.lovernet:getCache(libs.net.op.get_resources))
    self.lovernet:clearCache(libs.net.op.get_resources)
  end

  if self.lovernet:getCache(libs.net.op.get_points) then
    self.points:setPointsValue(self.lovernet:getCache(libs.net.op.get_points))
    self.lovernet:clearCache(libs.net.op.get_points)
  end

  self.gather:update(dt)
  self.points:update(dt)
  self.resources:update(dt)
  self.actionpanel:update(dt)
  self.selection:update(dt)
  self.buildqueue:update(dt,self.user,self.objects,self.resources,self.points,self.lovernet)
  if self.buildqueue:showPanel() then
    self.buildqueue:updateData(self.selection:getSelected()[1],self.resources)
  end
  self.fow:updateAll(dt,self.objects,self.user,self.players)
  self.explosions:update(dt)
  self.moveanim:update(dt)
  self.notif:update(dt)
  self.chat:update(dt)
  self:stackSide()
  self.matchstats:update(dt)

  self.gamestatus:update(dt,self.objects,self.players or {})
  if self.gamestatus:isStarted() then
    self.mpdisconnect:update(dt)
    if self.gamestatus:isPlayerLose(self.user) then
      self.mpdisconnect:setLose()
    elseif self.gamestatus:isPlayerWin(self.user) then
      self.mpdisconnect:setWin()
    end
  else
    self.mpconnect:update(dt)
    if self.config then
      self.mpconnect:setAiCount(self.config.ai)
      self.mpconnect:setCreative(self.config.creative)
      self.mpconnect:setPreset(self.config.preset or 1)
      self.mpconnect:setPoints(self.config.points or 1)
      self.points:setPoints(self.config.points or 1)
    end
    if self.config and self.players then
      self.mpconnect:updateData(self.config,self.players)
    end
  end

  if self.last_selected_timeout then
    self.last_selected_timeout = self.last_selected_timeout - dt
    if self.last_selected_timeout <= 0 then
      self.last_selected_timeout = nil
      self.last_selected = nil
    end
  end

  self.interruptable_move = love.keyboard.isDown("lshift")
  if not self.interruptable_move then
    libs.cursor.change("default")
  else
    libs.cursor.change("enemy")
  end

  local change = false

  for object_index,object in pairs(self.objects) do

    -- todo: figure out client side only?
    if object.gather then
      object.gather = object.gather - dt
      if object.gather <= 0 then
        object.gather = nil
      end
      self.gather:add(object.dx,object.dy,object.user)
    end

    if self.user and self.user.id == object.user and object.in_combat then
      if self.player_in_combat == nil then
        self.notif:add(
          libs.i18n('mission.notification.enemy_engage'),
          libs.sfx.get("notif.enemy"),
          {63,15,15,256*7/8},
          {255,0,0}
        )
      end
      self.player_in_combat = 5
      object.in_combat = object.in_combat - dt
      if object.in_combat <= 0 then
        object.in_combat = nil
      end
    end

    libs.objectrenderer.update(object,self.objects,dt,self.time,self.user)
    if object.user == self.user.id then
      self.fow:update(dt,object)
    end
    if libs.net.objectShouldBeRemoved(object) then
      if object.user == self.user.id then
        change = true
      end
      local object_type = libs.objectrenderer.getType(object.type)
      local explosion_count = 1
      local explosion_range = object_type.size
      if object_type.explode then
        explosion_count = 50
        explosion_range = object_type.explode.damage_range
      end
      for i = 1,explosion_count do
        self.explosions:add(object,explosion_range)
      end
      table.remove(self.objects,object_index)
    end
  end

  if self.player_in_combat then
    self.player_in_combat = self.player_in_combat - dt
    if self.player_in_combat <= 0 then
      self.player_in_combat = nil
    end
  end

  if change then
    self.resources:calcCargo(self.objects,self.user)
    self.selection:onChange()
  end

  for bullet_index,bullet in pairs(self.bullets) do
    local keep = libs.bulletrenderer.update(bullet,self.bullets,self.objects,dt,self.time)
    if not keep then
      self.explosions:add(bullet,32)
      table.remove(self.bullets,bullet_index)
    end
  end

  if self.menu_enabled then

    self.menu:update(dt)

  elseif self.mpresearch:active() then

    self.mpresearch:update(dt)

  else

    if not self.chat:getActive() and love.keyboard.isDown("space") then
      local avgx,avgy,avgc = 0,0,0
      for _,object in pairs(self.selection:getSelected()) do
        avgx = avgx + object.dx
        avgy = avgy + object.dy
        avgc = avgc + 1
      end
      if avgc > 0 then
        self.camera.x,self.camera.y = avgx/avgc,avgy/avgc
      elseif self.focusObject then
        self.camera.x = self.focusObject.dx
        self.camera.y = self.focusObject.dy
      end
    end

    local dx,dy =0,0
    if self:mouseInsideUI() then
      if not self.chat:getActive() then
        dx,dy = libs.camera_edge.get_keyb_delta(dt)
      end
    else
      dx,dy = libs.camera_edge.get_dual_delta(dt)
    end
    self.camera:move(dx,dy)

    if self.minimap:mouseInside() and not self.selection:selectionInProgress() then
      if love.mouse.isDown(1) then
        self.minimap:moveToMouse(self.camera)
      end
    end
  end

end

function client:mouseInsideUI()
  return self.minimap:mouseInside() or
    self.points:mouseInside() or
    self.resources:mouseInside() or
    self.actionpanel:mouseInside() or
    self.buildqueue:mouseInside() or
    self.selection:mouseInside() or
    self.chat:mouseInside()
end

function client:CartArchSpiral(initRad,turnDistance,angle)
  local x = (initRad+turnDistance*angle)*math.cos(angle)
  local y = (initRad+turnDistance*angle)*math.sin(angle)
  return round(x),round(y)
end

function client:distanceDraw(a,b)
  return math.sqrt( (a.dx - b.dx)^2  + (a.dy - b.dy)^2 )
end

function client:findNearestDraw(objects,x,y,include)
  local nearest,nearest_distance = objects[1],math.huge
  for _,object in pairs(objects) do
    if include == nil or include(object) then
      local distance = self:distanceDraw({dx=x,dy=y},object)
      if distance < nearest_distance then
        nearest,nearest_distance = object,distance
      end
    end
  end
  return nearest,nearest_distance
end

function client:distanceTarget(a,b)
  local ax = a._ttx or a.tx or a.x
  local ay = a._tty or a.ty or a.y
  local bx = b._ttx or b.tx or b.x
  local by = b._tty or b.ty or b.y
  return math.sqrt( (ax - bx)^2  + (ay - by)^2 )
end

function client:findNearestTarget(objects,x,y,include)
  local nearest,nearest_distance = nil,math.huge
  for _,object in pairs(objects) do
    if include == nil or include(object) then
      local distance = self:distanceTarget({tx=x,ty=y},object)
      if distance < nearest_distance then
        nearest,nearest_distance = object,distance
      end
    end
  end
  return nearest,nearest_distance
end

function client:moveSelectedObjects(x,y)
  local moves = {}
  local curAngle = 0
  local selected = self.selection:getSelected()
  local unselected = self.selection:getUnselected(self.objects)
  local send_move_command = true
  for _,object in pairs(self.selection:getSelected()) do

    if object.user ~= self.user.id then
      send_move_command = false
    end

    local tx = x
    local ty = y
    if #selected > 1 then
      local cx,cy
      repeat
        cx,cy = self:CartArchSpiral(8,8,curAngle)
        local n,nd = client:findNearestTarget(
          unselected,
          tx+cx,
          ty+cy,
          function(object)
            return object.tx ~= x and object.ty ~= y
          end
        )
        curAngle = curAngle + math.pi/32
      until n == nil or nd > 48
      object._ttx=tx+cx
      object._tty=ty+cy
      tx = tx+cx
      ty = ty+cy
    end

    object.anim = 1

    table.insert(unselected,object)
    table.insert(moves,{
      i=object.index,
      x=tx,
      y=ty,
    })
    curAngle = curAngle + math.pi/32
    local color = self.interruptable_move and {255,0,0} or {0,255,255}
    self.moveanim:add(x-self:getCameraOffsetX(),y-self:getCameraOffsetY(),color,self.camera)
  end
  -- todo: do not attempt to move objects without speed
  if send_move_command and #moves > 0 then
    self.lovernet:sendData(libs.net.op.move_objects,{o=moves,int=self.interruptable_move})
    libs.sfx.loopGroup("move")
  end
  for _,object in pairs(self.selection:getSelected()) do
    object._ttx,object._tty = nil,nil
  end
end

function client:mousepressed(x,y,button)
  if self.menu_enabled then return end
  if self.mpresearch:active() then
    self.mpresearch:mousepressed(x,y,button)
  elseif button == 1 then
    if self.minimap:mouseInside(x,y) then
      -- nop
    elseif self.actionpanel:mouseInside(x,y) then
      -- nop
    elseif self.buildqueue:mouseInside(x,y) then
      -- nop
    elseif self.selection:mouseInside(x,y) then
      -- nop
    elseif self.chat:mouseInside(x,y) then
      -- nop
    else
      self.selection:start(
        x+self:getCameraOffsetX(),
        y+self:getCameraOffsetY())
    end
  end
end

function client:mousereleased(x,y,button)
  if self.menu_enabled then return end
  self.chat:setActive(false)
  if self.mpresearch:active() then
    self.mpresearch:mousereleased(x,y,button)
  elseif button == 1 then
    if self.minimap:mouseInside(x,y) and not self.selection:selectionInProgress() then
      -- nop
    elseif self.actionpanel:mouseInside(x,y) and not self.selection:selectionInProgress() then
      self.actionpanel:runHoverAction()
    elseif self.buildqueue:mouseInside(x,y) and not self.selection:selectionInProgress() then
      self.buildqueue:runHoverAction()
    elseif self.selection:mouseInside(x,y) and not self.selection:selectionInProgress() then
      self.selection:runHoverAction()
    elseif self.chat:mouseInside(x,y) and not self.selection:selectionInProgress() then
      self.chat:setActive(true)
    else

      for _,object in pairs(self.selection:getSelected()) do
        if object.user ~= self.user.id then
          self.selection:clearSelected()
        end
      end

      if not love.keyboard.isDown('lshift') then
        self.selection:clearSelected()
      end

      if self.selection:isSelection(x+self:getCameraOffsetX(),y+self:getCameraOffsetY()) then

        self.selection:endAdd(
          x+self:getCameraOffsetX(),
          y+self:getCameraOffsetY(),
          self.objects)

      else -- not self.selection:isSelection

        self.selection:clearSelection()
        local closest_object,closest_object_distance = self:findNearestDraw(
          self.objects,
          x+self:getCameraOffsetX(),
          y+self:getCameraOffsetY()
        )
        if self.last_selected and self.last_selected == closest_object then
          if self.last_selected.user == self.user.id then
            self.last_selected = nil
            self.last_selected_timeout = nil
            for _,object in pairs(self.objects) do
              if object.user == self.user.id and object.type == closest_object.type and self:isOnCamera(object) then
                self.selection:add(object)
              end
            end
          end
        else
          self.last_selected = closest_object
          self.last_selected_timeout = 0.5 -- default for windows
          if closest_object then
            local type = libs.objectrenderer.getType(closest_object.type)
            if closest_object_distance <= type.size then
              if closest_object.user == self.user.id then
                self.selection:addOrRemove(closest_object)
              else
                self.selection:setSingleSelected(closest_object)
              end
            end
          end
        end

      end -- end of self.selection:isSelection

    end
  elseif button == 2 then

    if self.minimap:mouseInside() and not self.selection:selectionInProgress() then
      local nx,ny = self.minimap:getRealCoords()
      self:moveSelectedObjects(nx,ny)
    else

      local n,nd = self:findNearestDraw(
        self.objects,
        x+self:getCameraOffsetX(),
        y+self:getCameraOffsetY()
      )

      if n then
        local type = libs.objectrenderer.getType(n.type)
        if nd <= type.size then
          local targets = {}
          n.anim = 1
          for _,object in pairs(self.selection:getSelected()) do
            table.insert(targets,{i=object.index,t=n.index})
            object.anim = 1
          end
          self.lovernet:sendData(libs.net.op.target_objects,{t=targets})
        else
          self:moveSelectedObjects(
            x+self:getCameraOffsetX(),
            y+self:getCameraOffsetY())
        end
      end

    end

  end
end

function client:keypressed(key)

  if not self.chat:getActive() and key == "`" then
    debug_mode = not debug_mode
  end
  if debug_mode then
    if key == "c" then
      self.lovernet:sendData(libs.net.op.debug_create_object,{
        x=love.mouse.getX()+self:getCameraOffsetX(),
        y=love.mouse.getY()+self:getCameraOffsetY(),
        c=love.keyboard.isDown("lshift") and 100 or 1,
      })
    end
    if key == "p" then
      if self.lovernetprofiler then
        self.lovernetprofiler = nil
      else
        self.lovernetprofiler = libs.lovernetprofiler.new{
          lovernet=self.lovernet,
            x=256,
            y=32,
        }
      end
    end
    if key == "a" then
      self.soundtrack:nextTrack()
    end
  end

  if key == "escape" then
    if self.mpresearch:active() then
      self.mpresearch:setActive(false)
    elseif self.chat:getActive() then
      self.chat:setActive(false)
      self.chat:setBuffer("")
    else
      self.menu_enabled = not self.menu_enabled
    end
  end

  if debug_mode and key == "r" then -- todo: remove for prod
    self.mpresearch:setActive(true)
  end

  if self.mpresearch:active() then

  else

    if key == "return" or key == "kpenter" then
      if self.chat:getActive() then
        if self.chat:getBuffer() ~= "" then
          self.lovernet:sendData(libs.net.op.add_chat,{
            t=self.chat:getBuffer(),
          })
          self.chat:setBuffer("")
        end
        self.chat:setActive(false)
      else
        self.chat:setActive(true)
      end
    end

    if self.chat:getActive() then
      if key == "backspace" then
        local buffer = self.chat:getBuffer()
        local byteoffset = utf8.offset(buffer, -1)
        if byteoffset then
          buffer = string.sub(buffer, 1, byteoffset - 1)
        end
        self.chat:setBuffer(buffer)
      end
    else
      if key == "z" then
        self.chat:toggleHeight()
      end
      if key == "delete" then
        self.lovernet:sendData(libs.net.op.delete_objects,{
          d=self.selection:getSelectedIndexes(),
        })
      end
      self.controlgroups:keypressed(key,self.selection,self.notif,self.user)
    end
  end

end

function client:textinput(char)
  if self.chat:getActive() then
    self.chat:setBuffer(self.chat:getBuffer()..char)
  end
end

function client:resize()
  if self.fow then self.fow:resize() end
end

function client:lookAtObject(object)
  self.camera.x = object.dx or object.x
  self.camera.y = object.dy or object.y
end

function client:isOnCamera(ent)
  local range = 128
  local x = self.camera.x-love.graphics.getWidth()/2-range
  local y = self.camera.y-love.graphics.getHeight()/2-range
  local w = love.graphics.getWidth() + range*2
  local h = love.graphics.getHeight() + range*2
  return ent.dx > x and ent.dx < x + w and
    ent.dy > y and ent.dy < y + h
end

client.drawOrder = {
  function(object_user,user_id) return object_user == nil end,
  function(object_user,user_id) return object_user ~= user_id end,
  function(object_user,user_id) return object_user == user_id end,
}

function client:draw()

  libs.stars:draw(self.camera.x/2,self.camera.y/2)
  self.planets:draw()
  self.camera:attach()

  self.gather:draw()

  local drawn_objects = 0
  local drawable_objects = {}
  for _,object in pairs(self.objects) do
    if self:isOnCamera(object) then
      drawn_objects = drawn_objects + 1
      table.insert(drawable_objects,object)
      libs.objectrenderer.drawChevron(object,self.selection)
    end
  end
  for _,drawLayer in pairs(client.drawOrder) do
    for _,object in pairs(drawable_objects) do
      if drawLayer(object.user,self.user.id) then
        libs.objectrenderer.draw(object,self.objects,self.selection,self.time)
      end
    end
  end

  local drawn_bullets = 0
  for bullet_index,bullet in pairs(self.bullets) do
    if self:isOnCamera(bullet) then
      drawn_bullets = drawn_bullets + 1
      libs.bulletrenderer.draw(bullet,self.objects,self.time)
    end
  end

  self.explosions:draw()
  self.selection:draw(self.camera)

  self.camera:detach()
  if not self.gamestatus:isStarted() or self.gamestatus:isPlayerAlive(self.user) then
    self.fow:draw(self.objects,{},self.user,self.players)
  end
  self.camera:attach()
  self.moveanim:draw()

  if #self.selection:getSelected() == 1 then
    local object = self.selection:getSelected()[1]
    local object_type = libs.objectrenderer.getType(object.type)

    local name = object_type.loc.name or ""
    if object_type.names then
      name = object_type.names[object.name]
    end

    tooltipf(
      name.." — "..(object_type.loc.info or ""),
      object.dx+object_type.size,
      object.dy+object_type.size,
      320,"right")
  end

  self.camera:detach()

  if self.focusObject and self.user then
    self.minimap:draw(
      self.camera,
      self.focusObject,
      self.objects,
      self.fow,
      self.players,
      self.user,
      not self.gamestatus:isPlayerAlive(self.user)
    )
    if self.points:panelShown() then
      self.points:draw()
    end
    self.resources:draw()
    self.selection:drawPanel()
    if self.actionpanel:showPanel() then
      self.actionpanel:draw()
    end
    if self.buildqueue:showPanel() then
      self.buildqueue:drawPanel()
    end
  end

  self.notif:draw()
  if self.gamestatus:isStarted() then
    self.mpdisconnect:draw()
    if self.mpresearch:active() then
      self.mpresearch:draw(self.user)
    end
  else
    self.mpconnect:draw(self.config,self.players,self.user_count)
  end

  self.chat:draw()

  if self.lovernetprofiler then
    self.lovernetprofiler:draw()
  end

  local time_delta = self.time - self.last_time
  if self.last_time ~= 0 and time_delta > 1 then
    libs.loading.draw("Server is not responding ... ["..math.floor(time_delta).."s]")
  elseif self.user and self.user.np then
    libs.loading.draw("Game currently in progress ...")
  end

  if love.keyboard.isDown("tab") and self.gamestatus:isStarted() then
    self.matchstats:draw(self.players,self.user,math.floor(self.time-self.start_time))
  end

  if debug_mode then

    for i,v in pairs(libs.net._users) do
      love.graphics.setColor(v.selected_color)
      love.graphics.rectangle("fill",16*i+256,16,16,16)
      love.graphics.setColor(255,255,255)
    end

    local str = love.timer.getFPS( ).." FPS\n"
    if self.user then
      str = str .. "user.id: " .. libs.net.getUser(self.user.id).name .. "["..self.user.id.."]\n"
      str = str .. "not playing: " .. tostring(self.user.np) .. "\n"
      love.graphics.setColor(255,255,255)
    else
      str = str .. "loading user ... \n"
    end
    str = str .. "time: " .. self.time .. "\n"
    str = str .. "last_time: " .. self.last_time .. "\n"
    str = str .. "objects: " .. #self.objects .. "\n"
    str = str .. "drawn_objects: " .. drawn_objects .. "\n"
    str = str .. "drawn_bullets: " .. drawn_bullets .. "\n"
    str = str .. "update_index: " .. self.update_index .. "\n"
    str = str .. "bullet_index: " .. self.bullet_index .. "\n"
    str = str .. "connected users: " .. self.user_count .. "\n"
    str = str .. "camera: "..math.floor(self.camera.x)..","..math.floor(self.camera.y).."\n"
    if self.server_git_count ~= git_count then
      str = str .. "mismatch: " .. git_count .. " ~= " .. tostring(self.server_git_count) .. "\n"
    end
    str = str .. self.soundtrack:debugInfo()
    if self.players then
      for player_index,player in pairs(self.players) do
        str = str .. player_index .. "-" .. (player.user_name or "AI") .. " [team ".. player.team .. "]" .. "\n"
      end
    end
    love.graphics.printf(str,32,32,love.graphics.getWidth()-64,"right")
    libs.version.draw()
  end

  if self.menu_enabled then
    love.graphics.setColor(0,0,0,191)
    love.graphics.rectangle("fill",0,0,love.graphics:getWidth(),love.graphics:getHeight())
    love.graphics.setColor(255,255,255)
    self.menu:draw()
  end

end

return client
