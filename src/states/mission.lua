local mission = {}

function mission:init()

  self.explosion_images = {}
  self.explosions = {}

  for i = 1,6 do
    table.insert(
      self.explosion_images,
      love.graphics.newImage("assets/explosions/b"..i..".png")
    )
  end

  self.speed_mult = 2

  self.resources_types = {"ore","material","food","crew"}
  self.resources_types_formatted = {"Ore","Material","Food","Crew"}

  self.colors = {
    ui = {
      primary = {0,255,127},
    }
  }

  self.ship_types = {"enemy0","enemy1","drydock","mining","asteroid","combat","refinery","habitat","cargo"}

  local basic_explosion = love.audio.newSource("assets/sfx/explosion.ogg")
  self.ships = {}
  self.ships_icon = {}
  self.ships_death_sfx = {}
  for i,v in pairs(self.ship_types) do
    self.ships[v] = love.graphics.newImage("assets/ships/"..v..".png")
    self.ships_icon[v] = love.graphics.newImage("assets/ships/"..v.."_icon.png")
    self.ships_death_sfx[v] = basic_explosion
  end
  self.ships_death_sfx.asteroid = love.audio.newSource("assets/sfx/asteroid_death.ogg")

  self.ships_info = {
    enemy0 = "How did you get this, go away!",
    enemy1 = "How did you get this, go away!",
    drydock = "A construction ship with some ore and material storage and bio-production.",
    mining = "An ore mining ship with some ore storage.",
    asteroid = "Stop! You can't be an asteroid!",
    combat = "A combat ship to defend your squadron with.",
    refinery = "A material refining ship with some material storage.",
    habitat = "A bio-dome that produces food.",
    cargo = "A cargo ship that stores ore, material and food.",
  }

  self.sfx = {
    buildShip = love.audio.newSource("assets/sfx/build.ogg"),
    repairShip = love.audio.newSource("assets/sfx/repair.ogg"),
    refine = love.audio.newSource("assets/sfx/refine.ogg"),
    moving = {love.audio.newSource("assets/sfx/moving on my way.ogg"),
    love.audio.newSource("assets/sfx/moving ready.ogg"),
    love.audio.newSource("assets/sfx/moving yes commander.ogg"),},
    mining = love.audio.newSource("assets/sfx/mining.ogg"),
  }
  
  self.action_icons = {
    menu = love.graphics.newImage("assets/actions/repair.png"),
    repair = love.graphics.newImage("assets/actions/repair.png"),
    salvage = love.graphics.newImage("assets/actions/salvage.png"),
    refine = love.graphics.newImage("assets/actions/refine.png"),
    build_drydock = self.ships_icon.drydock,
    build_mining = self.ships_icon.mining,
    build_combat = self.ships_icon.combat,
    build_refinery = self.ships_icon.refinery,
    build_habitat = self.ships_icon.habitat,
    build_cargo = self.ships_icon.cargo,
  }
  --TODO: add passive icons, such as attack/mine

  self.bullets = {
    laser = love.graphics.newImage("assets/bullets/laser.png"),
  }

  self.ships_chevron = love.graphics.newImage("assets/chevron.png")
  self.target = love.graphics.newImage("assets/target.png")

  self.icon_bg = love.graphics.newImage("assets/icon_bg.png")
  self.camera = libs.hump.camera(1280/2,720/2)
  self.camera_speed = 300
  self.camera.vertical_mouse_move = 1/16.875
  self.camera.horizontal_mouse_move = 1/30

  self.space = love.graphics.newImage("assets/space.png")

  self.stars0 = love.graphics.newImage("assets/stars0.png")
  self.stars0:setWrap("repeat","repeat")
  self.stars0_quad = love.graphics.newQuad(0, 0,
    1280+self.stars0:getWidth(), 720+self.stars0:getHeight(),
    self.stars0:getWidth(), self.stars0:getHeight())

  self.stars1 = love.graphics.newImage("assets/stars1.png")
  self.stars1:setWrap("repeat","repeat")
  self.stars1_quad = love.graphics.newQuad(0, 0,
    1280+self.stars1:getWidth(), 720+self.stars1:getHeight(),
    self.stars1:getWidth(), self.stars1:getHeight())

  self.controlgroups = {}
  
  self.raw_planet_images = love.filesystem.getDirectoryItems("assets/planets/")
  self.planet_images = {}
  for i = 1, #self.raw_planet_images do
    self.planet_images[i] = love.graphics.newImage("assets/planets/" .. self.raw_planet_images[i])
  end
  
  self.resources = {
    material = math.huge,
    material_cargo = 0,
    material_delta = 0,
    ore = 0,
    ore_cargo = 0,
    ore_delta = 0,
    food = math.huge,
    food_cargo = 0,
    food_delta = 0,
    crew = math.huge,
    crew_cargo = 0,
    crew_delta = 0,
  }

  self.actions = {}
  
  self.actions.repair = {
    icon = "repair",
    tooltip = function(object) return "Auto Repair "..(object.repair and "Enabled" or "Disabled") end,
    exe = function(object)
      object.repair = not object.repair
    end,
  }

  self.actions.refine = {
    icon = "refine",
    tooltip = function(object) return "Auto Refine "..(object.refine and "Enabled" or "Disabled") end,
    exe = function(object)
      object.refine = not object.refine
    end,
  }

  self.actions.salvage = {
    icon = "salvage",
    tooltip = function(object) return "Salvage ship for 90% value" end,
    exe = function(object)
      local percent = object.health.current/object.health.max * 0.9
      for resource_type,cost in pairs( self.costs[object.type] ) do
        self.resources[resource_type] = self.resources[resource_type] + cost*percent
      end
      object.health.current = 0
      object.repair = false
    end,
  }

  self.costs = {
    enemy0 = {},
    enemy1 = {},
    drydock = {material=975,crew=100},
    mining = {material=85,crew=10},
    asteroid = {},
    combat = {material=250,crew=50},
    refinery = {material=110,crew=10},
    habitat = {material=105,crew=5},
    cargo = {material=345,crew=10},
  }

  self.build = {}

  self.build.drydock = function(parent)
    return {
      owner = parent.owner,
      type = "drydock",
      position = self:nearbyPosition(parent.position),
      size = 32,
      speed = 50,
      health = {
        max = 25,
      },
      death_sfx = self.ships_death_sfx.drydock,
      crew = self.costs.drydock.crew,
      ore = 400,
      material = 400,
      food = 100,
      food_gather = 10,
      repair = false,
      actions = {
        self.actions.salvage,
        self.actions.repair,
        self.actions.build_drydock,
        self.actions.build_mining,
        self.actions.build_refinery,
        self.actions.build_habitat,
        self.actions.build_combat,
        self.actions.build_cargo,
      }

    }
  end

  self.build.mining = function(parent)
    return {
      owner = parent.owner,
      type = "mining",
      position = self:nearbyPosition(parent.position),
      size = 32,
      speed = 50,
      health = {
        max = 10,
      },
      ore = 25,
      ore_gather = 25,
      death_sfx = self.ships_death_sfx.mining,
      crew = self.costs.mining.crew,
      repair = false,
      actions = {
        self.actions.salvage,
        self.actions.repair,
      }
    }

  end

  self.build.combat = function(parent)
    return {
      owner = parent.owner,
      type = "combat",
      position = self:nearbyPosition(parent.position),
      size = 32,
      speed = 100,
      health = {
        max = 50,
      },
      shoot = {
        reload = 0.25,
        damage = 2,
        speed = 200,
        range = 200,
        aggression = 400,
        sfx = love.audio.newSource("assets/sfx/laser_shoot.ogg"),
        collision_sfx = love.audio.newSource("assets/sfx/collision.ogg"),
      },
      death_sfx = self.ships_death_sfx.combat,
      crew = self.costs.combat.crew,
      repair = false,
      actions = {
        self.actions.salvage,
        self.actions.repair,
      }
    }
  end

  self.build.refinery = function(parent)
    return {
      owner = parent.owner,
      type = "refinery",
      position = self:nearbyPosition(parent.position),
      size = 32,
      speed = 50,
      health = {
        max = 10,
      },
    death_sfx = self.ships_death_sfx.refinery,
      crew = self.costs.refinery.crew,
      material = 50,
      material_gather = 5,
      repair = false,
      refine = true,
      actions = {
        self.actions.salvage,
        self.actions.repair,
        self.actions.refine,
      }
    }
  end

  self.build.habitat = function(parent)
    return {
      owner = parent.owner,
      type = "habitat",
      position = self:nearbyPosition(parent.position),
      size = 32,
      speed = 50,
      health = {
        max = 5,
      },
      death_sfx = self.ships_death_sfx.habitat,
      crew = self.costs.habitat.crew,
      food = 50,
      food_gather = 40,
      repair = false,
      actions = {
        self.actions.salvage,
        self.actions.repair,
      }
    }
  end

  self.build.cargo = function(parent)
    return {
      owner = parent.owner,
      type = "cargo",
      position = self:nearbyPosition(parent.position),
      size = 32,
      speed = 50,
      health = {
        max = 40,
      },
      death_sfx = self.ships_death_sfx.cargo,
      crew = self.costs.cargo.crew,
      ore = 100,
      material = 100,
      food = 100,
      repair = false,
      actions = {
        self.actions.salvage,
        self.actions.repair,
      }
    }
  end

  self.actions.build_drydock = {
    type = "drydock",
    icon = "build_drydock",
    tooltip = function(object)
      return "Build Dry Dock ["..self:makeCostString(self.costs.drydock).."]"
    end,
    exe = function(object)
      if self:buyBuildObject(self.costs.drydock) then
        local ship = self.build.drydock(object)
        table.insert(self.objects,ship)
      end
    end,
  }

  self.actions.build_mining = {
    type = "mining",
    icon = "build_mining",
    tooltip = function(object)
      return "Build Mining Rig ["..self:makeCostString(self.costs.mining).."]"
    end,
    exe = function(object)
      if self:buyBuildObject(self.costs.mining) then
        local ship = self.build.mining(object)
        table.insert(self.objects,ship)
      end
    end,
  }

  self.actions.build_combat = {
    type = "combat",
    icon = "build_combat",
    tooltip = function(object)
      return "Build Battlestar ["..self:makeCostString(self.costs.combat).."]" end,
    exe = function(object)
      if self:buyBuildObject(self.costs.combat) then
        local ship = self.build.combat(object)
        table.insert(self.objects,ship)
      end
    end,
  }

  self.actions.build_refinery = {
    type = "refinery",
    icon = "build_refinery",
    tooltip = function(object)
      return "Build Refinery ["..self:makeCostString(self.costs.refinery).."]"
    end,
    exe = function(object)
      if self:buyBuildObject(self.costs.refinery) then
        local ship = self.build.refinery(object)
        table.insert(self.objects,ship)
      end
    end,
  }

  self.actions.build_habitat = {
    type = "habitat",
    icon = "build_habitat",
    tooltip = function(object)
      return "Build Habitat ["..self:makeCostString(self.costs.habitat).."]"
    end,
    exe = function(object)
      if self:buyBuildObject(self.costs.habitat) then
        local ship = self.build.habitat(object)
        table.insert(self.objects,ship)
      end
    end,
  }

  self.actions.build_cargo = {
    type = "cargo",
    icon = "build_cargo",
    tooltip = function(object)
      return "Build Freighter ["..self:makeCostString(self.costs.cargo).."]"
    end,
    exe = function(object)
      if self:buyBuildObject(self.costs.cargo) then
        local ship = self.build.cargo(object)
        table.insert(self.objects,ship)
      end
    end,
  }

  self.objects = {}
  self.start = {
    owner = 0,
    position = {x=1280/2,y=720/2}
  }
  table.insert(self.objects,self.build.drydock(self.start))

  self.level = 0
  states.game:nextLevel()
end -- END OF INIT

function mission:enter()

end

function mission:hasNextLevel()
  return love.filesystem.exists("levels/"..(self.level+1)..".lua")
end

function mission:nextLevel()

  for i,v in pairs(self.objects) do
    if v.owner ~= 0  then
      table.remove(self.objects,i)
    end
  end

  self.level = self.level + 1

  local level_data = require("levels/"..self.level)
  self.vn = level_data:intro()
  if disable_vn then
    self.vn._run = false
  end

  if level_data.asteroid then
    for i = 1,level_data.asteroid do
      table.insert(self.objects,{
        type = "asteroid",
        position = {
          x = i == 1 and 1280*3/4 or math.random(0,32*128),
          y = i == 1 and 720*3/4 or math.random(0,32*128),
        },
        angle = math.random()*math.pi*2,
        size = 32,
        ore_supply = 100,
        death_sfx = self.ships_death_sfx.asteroid,
      })
    end
  end

  self.planets = {}
  for i = 1, 5 do
    self.planets[i] = {
      z = 0.1, -- paralax scrolling: the lower the Z, the slower the planets pan on camera
      x = math.random(0,1280)*1.5,
      y = math.random(0,720)*1.5,
      size = math.random(32,64)/64,
      rotation = math.random(32,64)/5120,
      img = self.planet_images[math.random(#self.planet_images)],
      angle = math.random()*math.pi*2,
    }
  end

  if level_data.enemy then
    for i = 1,level_data.enemy do
      table.insert(self.objects,{
        owner = 1,
        type = "enemy"..math.random(0,1),
        position = {
          x = math.random(0,32*128),
          y = math.random(0,32*128),
        },
        size = 32,
        speed = 100,
        health = {
          max = 50,
        },
        shoot = {
          reload = 0.25,
          damage = 2,
          speed = 200,
          range = 200,
          aggression = 400,
          sfx = love.audio.newSource("assets/sfx/laser_shoot.ogg"),
          collision_sfx = love.audio.newSource("assets/sfx/collision.ogg"),
        },
        death_sfx = self.ships_death_sfx.enemy0,
        crew = self.costs.combat.crew,
        repair = false,
        actions = {
          self.actions.salvage,
          self.actions.repair,
        }
      })
    end
  end
  
  self:regroupByOwner(0,128)
end

function mission:regroupByOwner(owner,scatter)
  --scatter is amount of pixels they move randomly after regroup
  for _,object in pairs(self:getObjectsByOwner(owner)) do
    object.position.x = self.start.position.x + math.random(-scatter,scatter)
    object.position.y = self.start.position.y + math.random(-scatter,scatter)
    object.target = nil
    object.target_object = nil
  end
  self.camera.x = 1280/2
  self.camera.y = 720/2
end


    -- Thanks Chris Nixon (ashlon23)!!! much love!

function mission:nearbyPosition(position)
  return {
    x = position.x + math.random(-32,32),
    y = position.y + math.random(-32,32),
  }
end

function mission:buyBuildObject(costs)
  local good = true
  for resource_type,cost in pairs(costs) do
    if self.resources[resource_type] < cost then
      good = false
      break
    end
  end
  if good then
    for resource_type,cost in pairs(costs) do
      self.resources[resource_type] = self.resources[resource_type] - cost
    end
    playSFX(self.sfx.buildShip)
    return true
  else
    return false
  end
end

function mission:makeCostString(costs)
  local s = {}
  for resource_type,cost in pairs(costs) do
    table.insert(s,resource_type..": "..cost)
  end
  return table.concat(s," + ")
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
  if self.vn:getRun() then
    self.vn:next()
    return
  end
  if self:mouseInMiniMap() then
  elseif self:mouseInSelected() then
    local pos = math.floor((love.mouse.getX()-32)/(32+self:iconPadding()))+1
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
  elseif self:mouseInActions() then
    local cobject = self:singleSelected()
    if cobject and cobject.actions then
      local pos = math.floor((love.mouse.getY()-32)/(32+self:iconPadding()))+1
      for ai,a in pairs(cobject.actions) do
        if ai == pos then
          a.exe(cobject)
        end
      end
    end
  elseif self:mouseInButton() then
    self.show_button = false
    if self:hasNextLevel() then
      self:nextLevel()
    else
      libs.hump.gamestate.switch(states.win)
    end
  else

    local ox,oy = self:getcameraoffset()
    local closest_object, closest_object_distance = self:findClosestObject(x+ox,y+oy)

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
            playSFX(self.sfx.moving)
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
                playSFX(self.sfx.moving)
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
  if key == "escape" then
    libs.hump.gamestate.switch(states.pause)
    self.select_start = nil
  end

  if self.vn:getRun() then
    self.vn:next()
    return
  end

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
  if self.vn:getRun() then return end
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

  for i = 1, #self.planets do
    local x = self.planets[i].x - self.camera.x * self.planets[i].z
    local y = self.planets[i].y - self.camera.y * self.planets[i].z
    love.graphics.draw(self.planets[i].img,x,y,
      self.planets[i].angle,
      self.planets[i].size,self.planets[i].size,
      self.planets[i].img:getWidth()/2,self.planets[i].img:getHeight()/2)
    --love.graphics.circle("line",x,y,4)
  end
  
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

    if object.health and object.health.current then
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

  for ei,explosion in pairs(self.explosions) do
    local index = math.floor(explosion.dt)+1
    local img = self.explosion_images[index]
    if img then
      love.graphics.draw(img,
        explosion.x,explosion.y,
        explosion.angle,1,1,
        img:getWidth()/2,
        img:getHeight()/2)
    else
      table.remove(self.explosions,ei)
    end
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
  self:drawActions()
  self:drawButton()

  for rindex,r in pairs(self.resources_types) do
    if self.resources[r.."_delta"] < 0 then
      love.graphics.setColor(255,0,0)
    else
      love.graphics.setColor(0,255,0)
    end
    dropshadow(
      self.resources_types_formatted[rindex]..": "..
      math.floor(self.resources[r]).."/"..self.resources[r.."_cargo"]..
      " [Δ"..math.floor(self.resources[r.."_delta"]+0.5).."]",
      32,128+64+18*rindex)
  end
  love.graphics.setColor(255,255,255)

  dropshadowf("Level "..self.level,32,720-32-8,1280-64,"right")

  if self.vn:getRun() then
    self.vn:draw()
  end

end

function mission:iconPadding()
  return 4
end

function mission:singleSelected()
  local count = 0
  local cobject = nil
  for _,object in pairs(self.objects) do
    if object.selected then
      count = count + 1
      cobject = object
      if count > 1 then
        break
      end
    end
  end
  return count == 1 and cobject or nil
end

function mission:drawActions()
  local cobject = self:singleSelected()
  if cobject and cobject.actions then
    for ai,a in pairs(cobject.actions) do
      local x,y = 1280-64,32+(ai-1)*(32+self:iconPadding())
      love.graphics.draw(self.icon_bg,x,y)
      if a.hover then
        dropshadowf(a.tooltip(cobject).."\n"..self:info(a.type),
        32,y+6,1280-96-8,"right")
        love.graphics.setColor(0,255,0)
      else
        love.graphics.setColor(255,255,255)
      end
      love.graphics.draw(self.action_icons[a.icon],x,y)
      love.graphics.setColor(255,255,255)
    end
  end
end

function mission:info(type)
  if self.ships_info[type] then
    return self.ships_info[type]
  else
    return ""
  end
end

function mission:drawSelected()
  -- TODO: add in rows when more selected
  local index = 0
  for _,object in pairs(self.objects) do
    if object.selected then
      local x,y = index*(32+self:iconPadding())+32,720-32-32
      love.graphics.draw(self.icon_bg,x,y)
      index = index + 1
      local ship_icon = self.ships_icon[object.type]
      local percent = object.health.current/object.health.max
      love.graphics.setColor(libs.healthcolor(percent))
      love.graphics.draw(ship_icon,x,y)
      love.graphics.setColor(255,255,255)
    end
  end
  local cobject = self:singleSelected()
  if cobject then
    dropshadow(self:info(cobject.type),64+8,720-64)
  end
end

function mission:buttonArea()
  local w = 320
  return (love.graphics.getWidth()-w)/2,love.graphics.getHeight()*1/8,w,32
end

function mission:drawButton()
  if self.show_button then
    local x,y,w,h = self:buttonArea()
    local t = "Continue journey, and leave system"
    if self:mouseInButton() then
      t = "[" .. t .. "]"
    end
    dropshadowf(t,x,y,w,"center")
  end
end

function mission:mouseInButton()
  if self.show_button then
    local x,y,w,h = self:buttonArea()
    local mx,my = love.mouse.getPosition()
    return mx >= x and mx <= x+w and my >= y and my <= y+h
  else
    return false
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

function mission:selectedArea()
  local count = 0
  for _,object in pairs(self.objects) do
    if object.selected then
      count = count + 1
    end
  end
  -- hacking hacking hack hack hack
  return 32,720-32-32,count*(32+self:iconPadding()),32
end

function mission:mouseInActions()
  local x,y,w,h = self:actionArea()
  local mx,my = love.mouse.getPosition()
  return mx >= x and mx <= x+w and my >= y and my <= y+h
end

function mission:actionArea()
  local cobject = mission:singleSelected()
  if cobject and cobject.actions then
    local count = -1
    for ia,a in pairs(cobject.actions) do
      count = count + 1
    end
    return 1280-64,32,32,32+count*(32+self:iconPadding())
  else
    return 0,0,0,0
  end
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

function mission:getObjectsByOwner(val)
  local OwnedObjects = {}
  for _,object in pairs(self.objects) do
    if object.owner == val then
      table.insert(OwnedObjects,object)
    end
  end
  return OwnedObjects
end

function mission:drawMinimap()
  local x,y,w,h = self:miniMapArea()
  love.graphics.setScissor(x-4,y-4,w+8,h+8)
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill",x,y,w,h)
  local scale = self:miniMapScale()
  love.graphics.setColor(self.colors.ui.primary)
  love.graphics.rectangle("line",x-4,y-4,w+8,h+8)
  local cx,cy,cw,ch = (self.camera.x-1280/2)/scale,(self.camera.y-720/2)/scale,1280/scale,720/scale
  love.graphics.rectangle("line",x+cx,y+cy,cw,ch)
  for _,object in pairs(self.objects) do
    love.graphics.setColor(self:ownerColor(object.owner))
    --love.graphics.points(x+object.position.x/scale,y+object.position.y/scale)
    love.graphics.rectangle("fill",
      x+object.position.x/scale,y+object.position.y/scale,2,2)
  end
  love.graphics.setScissor()
  love.graphics.setColor(255,255,255)
end

function mission:update(dt)

  if cheat then
    for _,resource in pairs(self.resources_types) do
      self.resources[resource] = math.huge
    end
  end

  if not self.vn:getRun() then
    self:updateMission(dt)
  else
    self.vn:update(dt)
  end

  if not love.window.hasFocus() then
    libs.hump.gamestate.switch(states.pause)
    self.select_start = nil
  end

  if cheat then
    self.show_button = true
  end

end

function mission:updateMission(dt)

  for _,e in pairs(self.explosions) do
    e.dt = e.dt + dt*#self.explosion_images*4
  end

  if self.target_show then
    if not self.target_show.anim_max then
      self.target_show.anim_max = self.target_show.anim
    end
    self.target_show.anim = self.target_show.anim - dt
    if self.target_show.anim <= 0 then
      self.target_show = nil
    end
  end

  for _,resource in pairs(self.resources_types) do
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
          bullet.x = bullet.x + math.cos(bullet.angle)*dt*bullet.speed*self.speed_mult
          bullet.y = bullet.y + math.sin(bullet.angle)*dt*bullet.speed*self.speed_mult
        else
          object.health.current = math.max(0,object.health.current-bullet.damage)
          table.remove(object.incoming_bullets,bullet_index)
          playSFX(bullet.collision_sfx)
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
        playSFX(object.shoot.sfx)
        table.insert(object.target_object.incoming_bullets,{
          speed = object.shoot.speed,
          damage = object.shoot.damage,
          collision_sfx = object.shoot.collision_sfx,
          x = object.position.x,
          y = object.position.y,
          angle = object.angle,
        })

      end
    end

    if object.refine and object.material_gather then
      local amount = object.material_gather*dt
      if amount > self.resources.ore then
        amount = self.resources.ore
      end
      if amount > 0 then
        loopSFX(self.sfx.refine)
      end
      self.resources.material = self.resources.material + amount
      self.resources.material_delta = self.resources.material_delta + amount/dt
      self.resources.ore = self.resources.ore - amount
      self.resources.ore_delta = self.resources.ore_delta - amount/dt
    end

    if object.repair then
      local amount_to_repair = math.min( (object.health.max - object.health.current) , object.health.max/10  )*dt
      if amount_to_repair < self.resources.material then
        if math.ceil(object.health.current) < math.ceil(object.health.max) then
          loopSFX(self.sfx.repairShip)
          --repairing
        else
          object.health.current = object.health.max
          --repair completed
        end
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
        loopSFX(self.sfx.mining)
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
      for _,resource in pairs(self.resources_types) do
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
        object.position.x = object.position.x + math.cos(object.angle)*dt*object.speed*self.speed_mult
        object.position.y = object.position.y + math.sin(object.angle)*dt*object.speed*self.speed_mult
      else
        if not object.target_object then
          object.position = object.target
          object.target = nil
        end
      end
    end

    if object.owner and object.owner ~= 0 and not object.wander then
      object.wander = {
        x = math.random(0,128*32),
        y = math.random(0,128*32),
      }
    end

    if object.wander then
      if self:distance(object.wander,object.position) < 4 then
        object.wander = nil
      end
    end

    if object.wander and not object.target and not object.target_object then
      local dx,dy = object.position.x-object.wander.x,object.position.y-object.wander.y
      object.angle = math.atan2(dy,dx)+math.pi
      object.position.x = object.position.x + math.cos(object.angle)*dt*object.speed*self.speed_mult/2
      object.position.y = object.position.y + math.sin(object.angle)*dt*object.speed*self.speed_mult/2
    end

  end -- end of object loop

  -- cleanup

  if #self:getObjectsByOwner(0) < 1 then
    libs.hump.gamestate.switch(states.lose)
  elseif #self:getObjectsByOwner(1) < 1 then
    self.show_button = true
  else
    self.show_button = false
  end

  for object_index,object in pairs(self.objects) do
    if (object.health and object.health.current and object.health.current <= 0) or
      (object.ore_supply and object.ore_supply <= 0) then

      table.remove(self.objects,object_index)
      table.insert(self.explosions,{
        x = object.position.x + math.random(-8,8),
        y = object.position.y + math.random(-8,8),
        angle = math.random()*math.pi*2,
        dt = 0,
      })
      playSFX(object.death_sfx)
    end

    if object.target_object and (
      (object.target_object.health and object.target_object.health.current <= 0) or
      (object.target_object.ore_supply and object.target_object.ore_supply <= 0 )) then

      object.target_object = nil
      object.target = {
        x = object.position.x+math.random(-128,128),
        y = object.position.y+math.random(-128,128),
      }
    end

  end

  for _,resource in pairs(self.resources_types) do
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

  for _,object in pairs(self.objects) do
    if object.actions then
      for _,a in pairs(object.actions) do
        a.hover = false
      end
    end
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
    elseif self:mouseInActions() then
      local cobject = self:singleSelected()
      if cobject and cobject.actions then
        local pos = math.floor((love.mouse.getY()-32)/(32+self:iconPadding()))+1
        for ai,a in pairs(cobject.actions) do
          if ai == pos then
            a.hover = true
          end
        end
      end
    elseif self:mouseInButton() then
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
