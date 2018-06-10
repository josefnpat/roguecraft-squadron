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

  self.music = love.audio.newSource("assets/music/Astrogator_v2.ogg","stream")
  self.music:setVolume(settings:read("music_vol"))
  self.music:setLooping(true)

end

function client:enter()

  self.lovernet = libs.lovernet.new{serdes=libs.bitser,ip=self._remote_address}
  -- todo: make common functions use short names
  self.lovernet:addOp(libs.net.op.git_count)
  self.lovernet:addOp(libs.net.op.user_count)
  self.lovernet:addOp(libs.net.op.get_user)
  self.lovernet:addOp(libs.net.op.debug_create_object)
  self.lovernet:addOp(libs.net.op.get_new_objects)
  self.lovernet:addOp(libs.net.op.get_new_updates)
  self.lovernet:addOp(libs.net.op.get_new_bullets)
  self.lovernet:addOp(libs.net.op.move_objects)
  self.lovernet:addOp(libs.net.op.target_objects)
  self.lovernet:addOp(libs.net.op.get_resources)
  self.lovernet:addOp(libs.net.op.time)
  self.lovernet:addOp(libs.net.op.action)

  -- init
  self.lovernet:pushData(libs.net.op.git_count)
  self.lovernet:pushData(libs.net.op.get_user)
  self.object_index = 0
  self.update_index = 0
  self.bullet_index = 0
  self.user_count = 0
  self.time = 0
  self.selection = libs.selection.new{onChange=client.selectionOnChange,onChangeScope=self}
  self.objects = {}
  self.bullets = {}
  self.menu_enabled = false
  self.focusObject = nil

  self.camera = libs.hump.camera(0,0)
  self.minimap = libs.minimap.new()
  self.fow = libs.fow.new{camera=self.camera}
  self.resources = libs.resources.new{}
  self.planets = libs.planets.new{camera=self.camera}
  self.actionpanel = libs.actionpanel.new()
  self.explosions = libs.explosions.new()
  self.gather = libs.gather.new()
  self.moveanim = libs.moveanim.new()

  self.music:play()

end

function client:leave()
  self.music:stop()
end

function client:selectionOnChange()
  self.actionpanel:process(self.selection,self.lovernet,self.user)
  for _,object in pairs(self.selection:getSelected()) do
    object.anim = 1
  end
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

function client:update(dt)

  if not self.menu_enabled then
    local dx,dy = libs.camera_edge.get_delta(dt)
    self.camera:move(dx,dy)
  end

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
  if not self.lovernet:hasData(libs.net.op.user_count) then
    self.lovernet:pushData(libs.net.op.user_count)
  end
  if not self.lovernet:hasData(libs.net.op.time) then
    self.lovernet:pushData(libs.net.op.time)
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
  end

  if self.lovernet:getCache(libs.net.op.time) then
    self.time = self.lovernet:getCache(libs.net.op.time)
  else
    self.time = self.time + dt
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
        sobject.dangle = sobject.angle
        if sobject.user == self.user.id then
          sobject.anim = 1
        end

        if not self.focusObject and sobject.user == self.user.id then
          self.focusObject = sobject
          self:lookAtObject(sobject)
          self.selection:setSingleSelected(sobject)
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
          if v == "nil" then
            object[i] = nil
          else
            object[i] = v
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

  self.gather:update(dt)
  self.resources:update(dt)
  self.actionpanel:update(dt)
  self.fow:updateAll(dt,self.objects,self.user)
  self.explosions:update(dt)
  self.moveanim:update(dt)

  local change = false

  for object_index,object in pairs(self.objects) do

    -- todo: figure out client side only?
    if object.gather then
      object.gather = object.gather - dt
      if object.gather <= 0 then
        object.gather = nil
      end
      self.gather:add(object.dx,object.dy)
    end

    libs.objectrenderer.update(object,self.objects,dt,self.time)
    if object.user == self.user.id then
      self.fow:update(dt,object)
    end
    if libs.net.objectShouldBeRemoved(object) then
      if object.user == self.user.id then
        change = true
      end
      local object_type = libs.objectrenderer.getType(object.type)
      self.explosions:add(object,object_type.size)
      table.remove(self.objects,object_index)
    end
  end

  if change then
    self.resources:calcCargo(self.objects,self.user)
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
  else
    if self.minimap:mouseInside() and not self.selection:selectionInProgress() then
      if love.mouse.isDown(1) then
        self.minimap:moveToMouse(self.camera)
      end
    end
  end

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
  local nearest,nearest_distance = nil,math.huge
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
  for _,object in pairs(self.selection:getSelected()) do

    local tx = x+self:getCameraOffsetX()
    local ty = y+self:getCameraOffsetY()
    if #selected > 1 then
      local cx,cy
      repeat
        cx,cy = self:CartArchSpiral(8,8,curAngle)
        local n,nd = client:findNearestTarget(
          unselected,
          cx+love.mouse.getX()+self:getCameraOffsetX(),
          cy+love.mouse.getY()+self:getCameraOffsetY(),
          function(object)
            return object.tx ~= x and object.ty ~= y
          end
        )
        curAngle = curAngle + math.pi/32
      until n == nil or nd > 48
      object._ttx=cx+love.mouse.getX()+self:getCameraOffsetX()
      object._tty=cy+love.mouse.getY()+self:getCameraOffsetY()
      tx = cx+love.mouse.getX()+self:getCameraOffsetX()
      ty = cy+love.mouse.getY()+self:getCameraOffsetY()
    end

    object.anim = 1

    table.insert(unselected,object)
    table.insert(moves,{
      i=object.index,
      x=tx,
      y=ty,
    })
    curAngle = curAngle + math.pi/32
    self.moveanim:add(love.mouse.getX(),love.mouse.getY(),self.camera)
  end
  -- todo: do not attempt to move objects without speed
  self.lovernet:sendData(libs.net.op.move_objects,{o=moves})
  for _,object in pairs(self.selection:getSelected()) do
    object._ttx,object._tty = nil,nil
  end
end

function client:mousepressed(x,y,button)
  if self.menu_enabled then return end
  if button == 1 then
    if self.minimap:mouseInside(x,y) then
      -- nop
    elseif self.actionpanel:mouseInside(x,y) then
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
  if button == 1 then
    if self.minimap:mouseInside() and not self.selection:selectionInProgress() then
      -- nop
    elseif self.minimap:mouseInside(x,y) and not self.selection:selectionInProgress() then
      -- nop
    elseif self.actionpanel:mouseInside(x,y) and not self.selection:selectionInProgress() then
      self.actionpanel:runHoverAction()
    else
      if self.selection:isSelection(x+self:getCameraOffsetX(),y+self:getCameraOffsetY()) then

        if love.keyboard.isDown('lshift') then
          self.selection:endAdd(
            x+self:getCameraOffsetX(),
            y+self:getCameraOffsetY(),
            self.objects)
        else
          self.selection:endSet(
            x+self:getCameraOffsetX(),
            y+self:getCameraOffsetY(),
            self.objects)
        end

      else

        self.selection:clearSelection()
        local closest_object,closest_object_distance = self:findNearestDraw(
          self.objects,
          x+self:getCameraOffsetX(),
          y+self:getCameraOffsetY()
        )

        if self.last_selected == closest_object then
          self.last_selected = nil
          self.last_selected_timeout = nil

          local new_selection = {}

          for _,object in pairs(self.objects) do
            if object.user == self.user.id and object.type == closest_object.type then
              self.selection:add(object)
            end
          end

        else

          self.last_selected = closest_object
          self.last_selected_timeout = 0.5 -- default for windows

          if closest_object then
            local type = libs.objectrenderer.getType(closest_object.type)
            if closest_object_distance <= type.size then
              self.selection:setSingleSelected(closest_object)
            end
          end

        end

      end
    end
  elseif button == 2 then

    if self.minimap:mouseInside() and not self.selection:selectionInProgress() then
      local nx,ny = self.minimap:getRealCoords()
      self:moveSelectedObjects(nx-self:getCameraOffsetX(),ny-self:getCameraOffsetY())
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
          self:moveSelectedObjects(x,y)
        end
      end

    end

  end
end

function client:keypressed(key)
  if debug_mode and key == "c" then
    self.lovernet:sendData(libs.net.op.debug_create_object,{
      x=love.mouse.getX()+self:getCameraOffsetX(),
      y=love.mouse.getY()+self:getCameraOffsetY(),
      c=love.keyboard.isDown("lshift") and 100 or 1,
    })
  end
  if key == "`" then
    debug_mode = not debug_mode
  end
  if key == "escape" then
    self.menu_enabled = not self.menu_enabled
  end
  if debug_mode and key == "p" then
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
end

function client:resize()
  self.fow:resize()
end

function client:lookAtObject(object)
  self.camera:move(
    self.focusObject.x+self.camera.x,
    self.focusObject.y+self.camera.y)
end

function client:draw()

  libs.stars:draw(self.camera.x/2,self.camera.y/2)
  self.planets:draw()
  self.camera:attach()

  self.gather:draw()

  for object_index,object in pairs(self.objects) do
    libs.objectrenderer.draw(object,self.objects,self.selection:isSelected(object),self.time)
  end

  for bullet_index,bullet in pairs(self.bullets) do
    libs.bulletrenderer.draw(bullet,self.objects,self.time)
  end

  self.explosions:draw()
  self.moveanim:draw()
  self.selection:draw(self.camera)

  if #self.selection:getSelected() == 1 then
    local object = self.selection:getSelected()[1]
    local object_type = libs.objectrenderer.getType(object.type)
    tooltipf(
      (object_type.loc.name or "").." — "..(object_type.loc.info or ""),
      object.dx+object_type.size,
      object.dy+object_type.size,
      320,"right")
  end

  self.camera:detach()
  self.fow:draw(self.objects,{},self.user)

  if self.focusObject then
    self.minimap:draw(self.camera,self.focusObject,self.objects,self.fow,self.user)
    self.resources:draw()
    self.actionpanel:draw()
  end

  if debug_mode then

    if self.lovernetprofiler then
      self.lovernetprofiler:draw()
    end

    for i,v in pairs(libs.net._users) do
      love.graphics.setColor(v.selected_color)
      love.graphics.rectangle("fill",16*i+256,16,16,16)
      love.graphics.setColor(255,255,255)
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
    str = str .. "bullet_index: " .. self.bullet_index .. "\n"
    str = str .. "connected users: " .. self.user_count .. "\n"
    str = str .. "camera: "..math.floor(self.camera.x)..","..math.floor(self.camera.y).."\n"
    if self.server_git_count ~= git_count then
      str = str .. "mismatch: " .. git_count .. " ~= " .. tostring(self.server_git_count) .. "\n"
    end
    love.graphics.printf(str,32,32,love.graphics.getWidth()-64,"right")
  end

  if self.menu_enabled then
    love.graphics.setColor(0,0,0,191)
    love.graphics.rectangle("fill",0,0,love.graphics:getWidth(),love.graphics:getHeight())
    love.graphics.setColor(255,255,255)
    self.menu:draw()
  end

end

return client
