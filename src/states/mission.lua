local mission = {}

function mission:init()
  self.colors = {
    ui = {
      primary = {0,255,127},
    }
  }
  self.ships = {
    enemy = love.graphics.newImage("ships/enemy.png"),
    drydock = love.graphics.newImage("ships/drydock.png"),
    mining = love.graphics.newImage("ships/mining.png"),
    asteroid = love.graphics.newImage("ships/asteroid.png"),
    combat = love.graphics.newImage("ships/combat.png"),
  }
  self.ships_icon = {
    enemy = love.graphics.newImage("ships/enemy_icon.png"),
    drydock = love.graphics.newImage("ships/drydock_icon.png"),
    mining = love.graphics.newImage("ships/mining_icon.png"),
    asteroid = love.graphics.newImage("ships/asteroid_icon.png"),
    combat = love.graphics.newImage("ships/combat_icon.png"),
  }

  self.bullets = {
    laser = love.graphics.newImage("bullets/laser.png"),
  }

  self.ships_chevron = love.graphics.newImage("chevron.png")
  self.target = love.graphics.newImage("target.png")

  self.icon_bg = love.graphics.newImage("icon_bg.png")
  self.camera = libs.hump.camera(1280/2,720/2)
  self.camera_speed = 300
  self.camera.vertical_mouse_move = 1/20
  self.camera.horizontal_mouse_move = 1/11.25

  self.space = love.graphics.newImage("space.png")

  self.stars0 = love.graphics.newImage("stars0.png")
  self.stars0:setWrap("repeat","repeat")
  self.stars0_quad = love.graphics.newQuad(0, 0,
    1280+self.stars0:getWidth(), 720+self.stars0:getHeight(),
    self.stars0:getWidth(), self.stars0:getHeight())

  self.stars1 = love.graphics.newImage("stars1.png")
  self.stars1:setWrap("repeat","repeat")
  self.stars1_quad = love.graphics.newQuad(0, 0,
    1280+self.stars1:getWidth(), 720+self.stars1:getHeight(),
    self.stars1:getWidth(), self.stars1:getHeight())

  self.controlgroups = {}

end

function mission:randomShipType()
  local ships = {}
  for i,v in pairs(self.ships) do
    table.insert(ships,i)
    -- Thanks Chris Nixon (ashlon23)!!! much love!
  end
  local val = ships[math.random(#ships)]
  return val == "asteroid" and "combat" or val
end

function mission:enter()

  self.resources = {
    material = 0,
    material_cargo = 0,
    material_delta = 0,
    ore = 0,
    ore_cargo = 0,
    ore_delta = 0,
    food = 0,
    food_cargo = 0,
    food_delta = 0,
    crew = 0,
    crew_cargo = 0,
    crew_delta = 0,
  }

  self.objects = {}
  for i = 1,50 do
    table.insert(self.objects,{
      owner = math.random(0,4) == 0 and 1 or 0,
      type = self:randomShipType(),
      position = {
        x = math.random(1280),
        y = math.random(720),
      },
      size = 32,
      speed = 100,
      health = {
        current = math.random(1,10),
        max = 10,
      },
      shoot = {
        reload = 0.25,
        damage = 2,
        speed = 200,
        range = 200,
        aggression = 400,
      },
      ore = 10,
      ore_gather = 25,
      material = 10,
      material_gather = 1,
      food = 100,
      food_gather = 10,
      crew = 100,
      cost = 10,
      repair = true,
    })
  end

  for i = 1,10 do
    table.insert(self.objects,{
      type = "asteroid",
      position = {
        x = math.random(0,1280),
        y = math.random(0,720),
      },
      size = 32,
      ore_supply = 100,
    })
  end

end


function mission:findClosestObject(x,y,include)
  local distance = math.huge
  local distance_object = nil
  for _,object in pairs(self.objects) do
    if include == nil or include(object) then
      local this_distance = self:distance({x=x,y=y},object.position)
      if this_distance < distance then
        distance = this_distance
        distance_object = object
      end
    end
  end
  return distance_object,distance
end

function mission:mousepressed(x,y,b)
  if self:mouseInMiniMap() then
  elseif self:mouseInSelected() then
    local pos = math.floor((love.mouse.getX()-32)/(32+self:selectedPadding()))+1
    local count = 0
    for _,object in pairs(self.objects) do
      if object.selected then
        object.selected = false
        count = count + 1
        if count == pos then
          object.selected = true
        end
      end
    end
  else

    local ox,oy = self:getcameraoffset()
    local closest_object, closest_object_distance = mission:findClosestObject(x+ox,y+oy)

    if b == 1 then
      if closest_object and closest_object.owner == 0 and closest_object_distance < 32 then
        for _,object in pairs(self.objects) do
          object.selected = false
        end
        closest_object.selected = true
        closest_object.anim = 0.25
      else
        self.select_start = {x=x,y=y}
      end
    elseif b == 2 then

      if closest_object and closest_object_distance < 32 then

        for _,object in pairs(self.objects) do
          if object.selected then
            object.target_object = closest_object
            object.target_object.anim = 0.25
          end
        end

      else

        local grid = {}
        local grid_size = 48
        for _,object in pairs(self.objects) do
          if not object.selected then
            local sx = object.target and object.target.x or object.position.x
            local sy = object.target and object.target.y or object.position.y
            local gx,gy = math.floor(sx/grid_size),math.floor(sy/grid_size)
            grid[gx] = grid[gx] or {}
            grid[gx][gy] = object
          end
        end
        for _,object in pairs(self.objects) do
          if object.selected then
            local range = 0
            local found = false
            while found == false do
              local rx,ry = x + math.random(-range,range),y + math.random(-range,range)
              local gx,gy = math.floor(rx/grid_size),math.floor(ry/grid_size)
              if not grid[gx] or not grid[gx][gy] then
                grid[gx] = grid[gx] or {}
                grid[gx][gy] = object
                local ox,oy = self:getcameraoffset()
                object.target = {x=gx*grid_size+ox,y=gy*grid_size+oy}
                object.anim = 0.25
                object.target_object = nil
                found = true
                self.target_show = {
                  x=self.camera.x+x-1280/2,
                  y=self.camera.y+y-720/2,
                  anim=0.25
                }
              end
              range = range + 0.1
            end
          end
        end

      end

    end
  end
end

function mission:keypressed(key)
  local key_number = tonumber(key)
  if key_number ~= nil and key_number >= 0 and key_number <= 9 then
    if love.keyboard.isDown("lctrl") then

      self.controlgroups[key_number] = {}
      for _,object in pairs(self.objects) do
        if object.selected and object.owner == 0 then
          table.insert(self.controlgroups[key_number],object)
        end
      end

    else

      if self.controlgroups[key_number] then
        for _,object in pairs(self.objects) do
          object.selected = false
          for _,tobject in pairs(self.controlgroups[key_number]) do
            if object == tobject then
              object.selected = true
              object.anim = 0.25
            end
          end
        end
      end

    end
  end
end

function mission:getcameraoffset()
  return self.camera.x-1280/2,self.camera.y-720/2
end

function mission:mousereleased(x,y,b)
  if b == 1 then
    if self.select_start then
      for _,object in pairs(self.objects) do
        local ox,oy = self:getcameraoffset()
        local xmin,ymin,xmax,ymax = self:selectminmax(self.select_start.x+ox,self.select_start.y+oy,x+ox,y+oy)
        if not love.keyboard.isDown("lshift") then
        object.selected = false
        end
        if object.position.x >= xmin and object.position.x <= xmax and
          object.position.y >= ymin and object.position.y <= ymax and object.owner == 0 then
            object.selected = true
            object.anim = 0.25
        end
        --print("selecting area:",xmin,ymin,xmax,ymax)
      end
      self.select_start = nil
    end
  end
end

function mission:selectminmax(x,y,x2,y2)
  local xmin = math.min(x,x2)
  local ymin = math.min(y,y2)
  local xmax = math.max(x,x2)
  local ymax = math.max(y,y2)
  return xmin,ymin,xmax,ymax
end

function mission:distance(a,b)
  return math.sqrt( (a.x-b.x)^2 + (a.y-b.y)^2 )
end

function mission:draw()

  love.graphics.draw(self.space)

  love.graphics.setBlendMode("add")

  love.graphics.draw(self.stars0, self.stars0_quad,
    -self.stars0:getWidth()+(self.camera.x%self.stars0:getWidth()),
    -self.stars0:getHeight()+(self.camera.y%self.stars0:getHeight()) )

  love.graphics.draw(self.stars1, self.stars1_quad,
    -self.stars1:getWidth()+((self.camera.x/2)%self.stars1:getWidth()),
    -self.stars1:getHeight()+((self.camera.y/2)%self.stars1:getHeight()) )

  love.graphics.setBlendMode("alpha")

  self.camera:attach()
  for _,object in pairs(self.objects) do
    if object.selected then
      love.graphics.setColor(self.colors.ui.primary)
      love.graphics.circle("line",object.position.x,object.position.y,object.size)
    end
    if object.anim then
      love.graphics.setColor(255,255,255,255*object.anim/(object.anim_max or object.anim))
      love.graphics.circle("line",object.position.x,object.position.y,
        object.size+object.anim/object.anim_max*4)
    end

    if object.health then
      local percent = object.health.current/object.health.max
      if (object.selected and percent < 1) or love.keyboard.isDown("lalt") then
        local bx,by,bw,bh = object.position.x-32,object.position.y+32,64,6
        love.graphics.setColor(0,0,0,127)
        love.graphics.rectangle("fill",bx,by,bw,bh)
        love.graphics.setColor(libs.healthcolor(percent))
        love.graphics.rectangle("fill",bx+1,by+1,(bw-2)*percent,bh-2)
      end
    end

    love.graphics.setColor(self:ownerColor(object.owner))
    love.graphics.draw(self.ships_chevron,
      object.position.x,object.position.y,0,1,1,
      self.ships_chevron:getWidth()/2,self.ships_chevron:getHeight()/2)

    love.graphics.setColor(255,255,255)
    if object.incoming_bullets then
      for _,bullet in pairs(object.incoming_bullets) do
        love.graphics.draw(self.bullets.laser,bullet.x,bullet.y,bullet.angle,
          1,1,self.bullets.laser:getWidth()/2,self.bullets.laser:getHeight()/2)
      end
    end

    local ship = self.ships[object.type]
    love.graphics.draw(ship,
      object.position.x,object.position.y,
      object.angle or 0,1,1,ship:getWidth()/2,ship:getHeight()/2)

  end

  if self.target_show then
    local percent = self.target_show.anim/self.target_show.anim_max
    love.graphics.setColor(0,255,0)
    love.graphics.draw(self.target,
      self.target_show.x,self.target_show.y,
      percent*math.pi/2,
      math.sqrt(percent),math.sqrt(percent),self.target:getWidth()/2,self.target:getHeight()/2)
  end

  self.camera:detach()
  love.graphics.setColor(self.colors.ui.primary)
  if self.select_start then
    local mx,my = love.mouse.getPosition()
    local xmin,ymin,xmax,ymax = self:selectminmax(self.select_start.x,self.select_start.y,mx,my)
    local w,h = xmax - xmin, ymax - ymin
    love.graphics.rectangle("line",xmin,ymin,w,h)
  end
  love.graphics.setColor(255,255,255)

  self:drawMinimap()
  self:drawSelected()

  dropshadow(
    "Ore: "..math.floor(self.resources.ore).."/"..self.resources.ore_cargo.."[Δ"..math.floor(self.resources.ore_delta+0.5).."]\n"..
    "Materials: "..math.floor(self.resources.material).."/"..self.resources.material_cargo.."[Δ"..math.floor(self.resources.material_delta+0.5).."]\n"..
    "Food: "..math.floor(self.resources.food).."/"..self.resources.food_cargo.."[Δ"..math.floor(self.resources.food_delta+0.5).."]\n"..
    "Crew: "..math.floor(self.resources.crew).."/"..self.resources.crew_cargo.."[Δ"..math.floor(self.resources.crew_delta+0.5).."]",
    32,128+64)

end

function mission:selectedPadding()
  return 4
end

function mission:selectedArea()
  local count = 0
  for _,object in pairs(self.objects) do
    if object.selected then
      count = count + 1
    end
  end
  -- hacking hacking hack hack hack
  return 32,720-32-32,count*(32+mission:selectedPadding()),32
end

function mission:drawSelected()
  -- TODO: add in rows when more selected
  local index = 0
  for _,object in pairs(self.objects) do
    if object.selected then
      local x,y = index*(32+self:selectedPadding())+32,720-32-32
      love.graphics.draw(self.icon_bg,x,y)
      index = index + 1
      local ship_icon = self.ships_icon[object.type]
      local percent = object.health.current/object.health.max
      love.graphics.setColor(libs.healthcolor(percent))
      love.graphics.draw(ship_icon,x,y)
      love.graphics.setColor(255,255,255)
    end
  end
end

function mission:miniMapArea()
  return 32,32,128,128
end

function mission:miniMapScale()
  return 32
end

function mission:mouseInMiniMap()
  local x,y,w,h = self:miniMapArea()
  local mx,my = love.mouse.getPosition()
  return mx >= x and mx <= x+w and my >= y and my <= y+h
end

function mission:mouseInSelected()
  local x,y,w,h = self:selectedArea()
  local mx,my = love.mouse.getPosition()
  return mx >= x and mx <= x+w and my >= y and my <= y+h
end

function mission:ownerColor(owner)
  if owner == 0 then
    return {0,255,0}
  elseif owner == nil then
    return {255,255,0}
  else
    return {255,0,0}
  end
end

function mission:drawMinimap()
  local x,y,w,h = self:miniMapArea()
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill",x,y,w,h)
  local scale = self:miniMapScale()
  love.graphics.setColor(self.colors.ui.primary)
  love.graphics.rectangle("line",x,y,w,h)
  local cx,cy,cw,ch = (self.camera.x-1280/2)/scale,(self.camera.y-720/2)/scale,1280/scale,720/scale
  love.graphics.rectangle("line",x+cx,y+cy,cw,ch)
  for _,object in pairs(self.objects) do
    love.graphics.setColor(self:ownerColor(object.owner))
    love.graphics.points(x+object.position.x/scale,y+object.position.y/scale)
  end
  love.graphics.setColor(255,255,255)
end

function mission:update(dt)

  if self.target_show then
    if not self.target_show.anim_max then
      self.target_show.anim_max = self.target_show.anim
    end
    self.target_show.anim = self.target_show.anim - dt
    if self.target_show.anim <= 0 then
      self.target_show = nil
    end
  end

  local resources_types = {"ore","material","food","crew"}
  for _,resource in pairs(resources_types) do
    self.resources[resource.."_cargo"] = 0
    self.resources[resource.."_delta"] = 0
  end

  for _,object in pairs(self.objects) do

    if object.incoming_bullets then
      for bullet_index,bullet in pairs(object.incoming_bullets) do
        local distance = self:distance(bullet,object.position)
        if distance > 4 then
          local dx,dy = bullet.x-object.position.x,bullet.y-object.position.y
          bullet.angle = math.atan2(dy,dx)+math.pi
          bullet.x = bullet.x + math.cos(bullet.angle)*dt*bullet.speed
          bullet.y = bullet.y + math.sin(bullet.angle)*dt*bullet.speed
        else
          object.health.current = math.max(0,object.health.current-bullet.damage)
          table.remove(object.incoming_bullets,bullet_index)
        end
      end
    end

    if object.health then
      if not object.health.current then
        object.health.current = object.health.max
      end
    end

    if object.anim then
      if not object.anim_max then
        object.anim_max = object.anim
      end
      object.anim = object.anim - dt
      if object.anim <= 0 then
        object.anim = nil
      end
    end

    if object.shoot then
      if object.shoot.reload_t == nil then
        object.shoot.reload_t = object.shoot.reload
      end
      object.shoot.reload = object.shoot.reload - dt
      if object.shoot.reload <= 0 and
        object.target_object and object.target_object.owner ~= object.owner and object.target_object.health and
        self:distance(object.position,object.target_object.position) < object.shoot.range then

        object.shoot.reload = object.shoot.reload_t
        object.target_object.incoming_bullets = object.target_object.incoming_bullets or {}
        table.insert(object.target_object.incoming_bullets,{
          speed = object.shoot.speed,
          damage = object.shoot.damage,
          x = object.position.x,
          y = object.position.y,
          angle = object.angle,
        })

      end
    end

    if object.material_gather then
      local amount = object.material_gather*dt
      if amount > self.resources.ore then
        amount = self.resources.ore
      end
      self.resources.material = self.resources.material + amount
      self.resources.material_delta = self.resources.material_delta + amount/dt
      self.resources.ore = self.resources.ore - amount
      self.resources.ore_delta = self.resources.ore_delta - amount/dt
    end

    if object.repair then
      local amount_to_repair = math.min( (object.health.max - object.health.current) , object.health.max/10  )*dt
      if amount_to_repair < self.resources.material then
        object.health.current = object.health.current + amount_to_repair
        self.resources.material = self.resources.material - amount_to_repair
        self.resources.material_delta = self.resources.material_delta - amount_to_repair/dt
      end
    end

    if object.food_gather then
      local amount = object.food_gather*dt
      self.resources.food = self.resources.food + amount
      self.resources.food_delta = self.resources.food_delta + amount/dt
    end

    if object.target_object then
      if object.ore_gather and object.target_object.ore_supply and
        self:distance(object.position,object.target_object.position) < 48 then

        local amount = object.ore_gather*dt
        self.resources.ore_delta = self.resources.ore_delta + amount/dt
        if object.target_object.ore_supply > amount then
          object.target_object.ore_supply = object.target_object.ore_supply - amount
          self.resources.ore = self.resources.ore + amount
        else
          self.resources.ore = self.resources.ore + object.target_object.ore_supply
          object.target_object.ore_supply = 0
        end

      end
      if object.target_object.health and object.target_object.health.current <= 0 then
        object.target_object = nil
        object.target = nil
      else
        object.target = {
          x=object.target_object.position.x,
          y=object.target_object.position.y,
        }
      end

    else
      if object.shoot and object.health then
        local cobject = object
        local nearest,nearest_distance = self:findClosestObject(object.position.x,object.position.y,function(object)
          return object.owner ~= cobject.owner and object.owner ~= nil
        end)
        if not object.target and nearest and nearest.health and nearest_distance < object.shoot.aggression then
          object.target_object = nearest
        end
      end
    end

    if object.owner and object.owner == 0 then
      for _,resource in pairs(resources_types) do
        if object[resource] then
          self.resources[resource.."_cargo"] = self.resources[resource.."_cargo"] + object[resource]
        end
      end
    end

    if object.target then
      local distance = self:distance(object.position,object.target)
      local range = 4
      if object.target_object then
        if object.shoot and object.target_object.owner ~= object.owner then
          range = object.shoot.range
        else
          range = 48
        end
      end
      if distance > range then
        local dx,dy = object.position.x-object.target.x,object.position.y-object.target.y
        object.angle = math.atan2(dy,dx)+math.pi
        object.position.x = object.position.x + math.cos(object.angle)*dt*object.speed
        object.position.y = object.position.y + math.sin(object.angle)*dt*object.speed
      else
        if not object.target_object then
          object.position = object.target
          object.target = nil
        end
      end
    end

  end

  -- cleanup
  for object_index,object in pairs(self.objects) do
    if (object.health and object.health.current <= 0) or
      (object.ore_supply and object.ore_supply <= 0) then

      table.remove(self.objects,object_index)
      -- TODO: add explosion
    end

    if object.target_object and (
      (object.target_object.health and object.target_object.health.current <= 0) or
      (object.target_object.ore_supply and object.target_object.ore_supply <= 0 )) then

      object.target_object = nil
    end

  end

  for _,resource in pairs(resources_types) do
    self.resources[resource] = math.min(self.resources[resource],self.resources[resource.."_cargo"])
  end

  local crew_amount = self.resources.crew_cargo/100*dt
  self.resources.crew_delta = self.resources.crew_delta + crew_amount/dt
  self.resources.crew = self.resources.crew + crew_amount
  local food_amount = self.resources.crew*dt
  self.resources.food = self.resources.food - food_amount
  self.resources.food_delta = self.resources.food_delta - food_amount/dt
  if self.resources.food < 0 then
    self.resources.crew = math.max(0,self.resources.crew + self.resources.food)
    self.resources.crew_delta = 0--self.resources.crew_delta - self.resources.food
    self.resources.food_delta = 0--
    self.resources.food = 0
  end

  if not self.select_start then

    if self:mouseInMiniMap() then
      if love.mouse.isDown(1) then
        local x,y,w,h = self:miniMapArea()
        local nx = (love.mouse.getX()-x)*self:miniMapScale()
        local ny = (love.mouse.getY()-y)*self:miniMapScale()
        self.camera:move(-self.camera.x + nx, -self.camera.y + ny)
      end
    elseif self:mouseInSelected() then
      -- nop
    else

      local left = love.keyboard.isDown("left") or love.mouse.getX() < 1280*self.camera.horizontal_mouse_move
      local right = love.keyboard.isDown("right") or love.mouse.getX() > 1280*(1-self.camera.horizontal_mouse_move)
      local up = love.keyboard.isDown("up") or love.mouse.getY() < 720*self.camera.vertical_mouse_move
      local down = love.keyboard.isDown("down") or love.mouse.getY() > 720*(1-self.camera.vertical_mouse_move)

      local dx,dy = 0,0
      if left then
        dx = -self.camera_speed*dt
      end
      if right then
        dx = self.camera_speed*dt
      end
      if up then
        dy = -self.camera_speed*dt
      end
      if down then
        dy = self.camera_speed*dt
      end
      self.camera:move(dx,dy)

    end

  end

end

return mission
