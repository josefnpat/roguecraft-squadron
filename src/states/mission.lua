local mission = {}

function mission:init()

  self.time = 0

  -- defaults
  self.multi = {
    refine = true,
    jump_process = true,
  }

  self.score = libs.score.new()
  self.score:define("kill","Killed","ship","ships",100)
  self.score:define("lost","Lost","ship","ships",100)
  self.score:define("scrap","Collected","scrap")
  self.score:define("ore","Collected","ore")
  self.score:define("crew","Saved","crew member","crew members")
  self.score:define("born","Raised","crew member","crew members",0)
  self.score:define("takeover","Boarded","ship","ships",100)
  self.score:define("egg","Found","easter egg","easter eggs",200)
  self.score:define("time","Game ended in","second","seconds",-1)--used to be -10

  self.jump_max = 60*5

  self:resize()
  self.fow_img = love.graphics.newImage("assets/fow.png")

  self.explosion_images = {}
  self.explosions = {}

  self.selected_row_max = 16

  for i = 1,6 do
    table.insert(
      self.explosion_images,
      love.graphics.newImage("assets/explosions/b"..i..".png")
    )
  end

  self.speed_mult = 2

  self.resources_types = {"ore","material","crew"}
  self.resources_types_formatted = {"Ore","Material","Crew"}

  self.colors = {
    ui = {
      primary = {0,255,127},
      secondary = {0,127,255},
    }
  }

  self.object_types = {}
  for _,object_fn in pairs(love.filesystem.getDirectoryItems("assets/objects_data")) do
    local object_type = getFileName(object_fn)
    table.insert(self.object_types,object_type)
  end

  self.objects_image = {}
  self.objects_icon = {}
  for i,v in pairs(self.object_types) do
    self.objects_image[v] = {}
    self.objects_icon[v] = {}
  end


  self.sfx_data = {
    jump = love.sound.newSoundData("assets/sfx/jump.ogg"),
  }

  self.sfx = {
    explosion = {
      basic = love.audio.newSource("assets/sfx/explosion.ogg"),
      asteroid = love.audio.newSource("assets/sfx/asteroid_death.ogg")
    },
    buildShip = love.audio.newSource("assets/sfx/build.ogg"),
    repairShip = love.audio.newSource("assets/sfx/repair.ogg"),
    refine = love.audio.newSource("assets/sfx/refine.ogg"),
    moving = {
      love.audio.newSource("assets/sfx/moving on my way.ogg"),
      love.audio.newSource("assets/sfx/moving ready.ogg"),
      love.audio.newSource("assets/sfx/moving yes commander.ogg"),
    },
    insufficient = {
      crew = love.audio.newSource("assets/sfx/voice insufficient crew.ogg"),
      material = love.audio.newSource("assets/sfx/voice insufficient material.ogg"),
      funds = love.audio.newSource("assets/sfx/voice insufficient funds.ogg"),
    },
    mining = love.audio.newSource("assets/sfx/mining.ogg"),
    salvaging = love.audio.newSource("assets/sfx/mining.ogg"),
    shoot = {
      laser = love.audio.newSource("assets/sfx/laser_shoot.ogg"),
      collision = love.audio.newSource("assets/sfx/collision.ogg"),
    },
    jump = love.audio.newSource(self.sfx_data.jump),
    jumpReady = love.audio.newSource("assets/sfx/voice ready for jump.ogg"),
  }

  self.objects_death_sfx = {}
  for i,v in pairs(self.object_types) do
    self.objects_death_sfx[v] = self.sfx.explosion.basic
  end
  self.objects_death_sfx.asteroid = self.sfx.explosion.asteroid

  self.action_icons = {
    menu = love.graphics.newImage("assets/actions/repair.png"),
    repair = love.graphics.newImage("assets/actions/repair.png"),
    salvage = love.graphics.newImage("assets/actions/salvage.png"),
    refine = love.graphics.newImage("assets/actions/refine.png"),
    jump = love.graphics.newImage("assets/actions/jump.png"),
    jump_process = love.graphics.newImage("assets/actions/jump_process.png"),
    collect = love.graphics.newImage("assets/actions/collect.png"),
    egg = love.graphics.newImage("assets/objects/cat0_icon.png"),
  }
  --TODO: add passive icons, such as attack/mine

  self.bullets = {
    laser = love.graphics.newImage("assets/bullets/laser.png"),
  }

  self.objects_chevron = love.graphics.newImage("assets/chevron.png")
  self.target = love.graphics.newImage("assets/target.png")

  self.map_bg = love.graphics.newImage("assets/map_bg.png")
  self.icon_bg = love.graphics.newImage("assets/icon_bg.png")
  self.camera = libs.hump.camera(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
  self.camera_speed = 300
  self.camera.vertical_mouse_move = 1/16.875
  self.camera.horizontal_mouse_move = 1/30

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
    crew = 50, -- used to be 10
    crew_cargo = 0,
    crew_delta = 0,
  }

  self.actions = {}

  self.actions.repair = {
    icon = "repair",
    tooltip = function(object) return "Auto Repair "..(object.repair and "Enabled" or "Disabled") end,
    color = function(object) return object.repair and {0,255,0} or {255,255,255} end,
    multi = {
      tooltip = function(object) return "Auto Repair All Ships "..(object.repair and "Enabled" or "Disabled") end,
      color = function(object) return object.repair and {0,255,0} or {255,255,255} end,
      exe = function(object)
        object.repair = not object.repair
        for _,tobject in pairs(self:getObjectsByOwner(0)) do
          if tobject.repair ~= nil then
            tobject.repair = object.repair
          end
        end
      end,
    },
    exe = function(object)
      object.repair = not object.repair
    end,
  }

  self.actions.refine = {
    icon = "refine",
    tooltip = function(object) return "Auto Refine "..(object.refine and "Enabled" or "Disabled") end,
    color = function(object) return object.refine and {0,255,0} or {255,255,255} end,
    multi = {
      tooltip = function(object) return "Fleet Wide Auto Refine "..(object.refine and "Enabled" or "Disabled") end,
      color = function(object) return object.refine and {0,255,0} or {255,255,255} end,
      exe = function(object)
        object.refine = not object.refine
        for _,tobject in pairs(self:getObjectsByOwner(0)) do
          if tobject.refine ~= nil then
            tobject.refine = object.refine
          end
        end
      end,
    },
    exe = function(object)
      object.refine = not object.refine
    end,
  }

  self.actions.salvage = {
    icon = "salvage",
    tooltip = function(object) return "Salvage ship for 90% value" end,
    color = function(object) return {255,0,0} end,
    exe = function(object)
      local percent = object.health.current/object.health.max * 0.9
      for resource_type,cost in pairs( object.cost ) do
        self.resources[resource_type] = self.resources[resource_type] + cost*percent
      end
      object.health.current = 0
      object.repair = false
      object.no_scrap_drop = true
    end,
  }

  self.actions.jump = {
    icon = "jump",
    tooltip = function(object)
      if #self:getObjectWithModifier("jump_disable") > 0 then
        return "Jump to the next sector (Disabled by Enemy)"
      end
      local percent = math.floor((1 - self.jump/self.jump_max)*1000)/10
      return self.jump <= 0 and
        "Jump to the next sector (Ready)" or
        ("Jump to the next sector (Calculating: "..percent.."%)")
    end,
    color = function(object)
      return (self.jump <= 0 and #self:getObjectWithModifier("jump_disable") == 0) and
        {0,255,0} or {255,0,0}
    end,
    exe = function(object)
      if self.jump <= 0 and #self:getObjectWithModifier("jump_disable") == 0 then
        self.jump_active = self.sfx_data.jump:getDuration()
        playSFX(self.sfx.jump)
      else
        --playSFX(self.sfx.insufficient.calibration)
      end
    end,
  }

  self.actions.jump_process = {
    icon = "jump_process",
    tooltip = function(object)
      return "Calculate Jump Coordinates "..(object.jump_process and "Enabled" or "Disabled")
    end,
    color = function(object)
      return object.jump_process and {0,255,0} or {255,255,255}
    end,
    multi = {
      tooltip = function(object)
        return "Fleet Wide Calculate Jump Coordinates "..(object.jump_process and "Enabled" or "Disabled")
      end,
      color = function(object) return object.jump_process and {0,255,0} or {255,255,255} end,
      exe = function(object)
        object.jump_process = not object.jump_process
        for _,tobject in pairs(self:getObjectsByOwner(0)) do
          if tobject.jump_process ~= nil then
            tobject.jump_process = object.jump_process
          end
        end
      end,
    },
    exe = function(object)
      object.jump_process = not object.jump_process
    end,
  }

  self.actions.collect = {
    icon = "collect",
    tooltip = function(object)
      return "Automatic Resource Collection "..(object.collect and "Enabled" or "Disabled")
    end,
    color = function(object)
      return object.collect and {0,255,0} or {255,255,255}
    end,
    multi = {
      tooltip = function(object)
        return "Fleet Wide Automatic Resource Collection "..(object.collect and "Enabled" or "Disabled")
      end,
      color = function(object) return object.collect and {0,255,0} or {255,255,255} end,
      exe = function(object)
        object.collect = not object.collect
        for _,tobject in pairs(self:getObjectsByOwner(0)) do
          if tobject.collect ~= nil then
            tobject.collect = object.collect
            if object.collect == false then
              tobject.target_object = nil
              tobject.target = nil
            end
          end
        end
      end,
    },
    exe = function(object)
      object.collect = not object.collect
    end,
  }

  self.actions.egg = {
    icon = "egg",
    tooltip = function(object) return "Fortune smiles upon you. Redeem for 100 materials" end,
    color = function(object) return object.owner == 0 and {0,255,0} or {255,0,0} end,
    exe = function(object)
      if object.owner == 0 then
        object.remove_from_game = true
        self.resources.material = self.resources.material + 100
      end
    end,
  }

  self.build = {}
  for i,v in pairs(self.object_types) do
    self.build[v] = require("assets.objects_data."..v)
  end

  for objtype,objbuildfn in pairs(self.build) do
    self.action_icons["build_"..objtype] =
      love.graphics.newImage("assets/objects/"..objtype.."0_icon.png")

    self.actions["build_"..objtype] = {
      type = objtype,
      icon = "build_"..objtype,
      color = function(object)
        local tobject = self.build[objtype]()
        return self:canAffordObject(tobject) and {0,255,0} or {127,127,127}
      end,
      tooltip = function(object)
        local tobject = self.build[objtype]()
        return "Build "..tobject.display_name.." ["..self:makeCostString(tobject.cost).."]\n"..tobject.info
      end,
      exe = function(object)
        if object.work == nil then
          local tobject = self.build[objtype]()
          object.work = {
            time = tobject.build_time,
            callback = function(object)
              if self:buyBuildObject(tobject.cost) then
                local object = self:build_object(objtype,object)
                table.insert(self.objects,object)
              end
            end,
          }
        else
          -- TODO: add queue
          -- unit already being built
        end
      end,
    }
  end

  self.objects = {}

  self.level = 0
  states.mission:nextLevel()

  self.start = {
    position = {x=love.graphics.getWidth()/2,y=love.graphics.getHeight()/2}
  }

  --[[
  table.insert(self.objects,self:build_object("troopship",{position=self.start.position,owner=0}))
  local abandoned_drydock = self:build_object("drydock",{position=self.start.position})
  abandoned_drydock.health.current = 1
  table.insert(self.objects,abandoned_drydock)
  --]]
  table.insert(self.objects,self:build_object("blackhole",{position={x=love.graphics.getWidth(),y=love.graphics.getHeight()}}))
  table.insert(self.objects,self:build_object("command",{position=self.start.position,owner=0}))
  table.insert(self.objects,self:build_object("jump",{position=self.start.position,owner=0}))

end -- END OF INIT

function mission:build_object(object_name,parent)
  local obj = self.build[object_name]()
  obj.position = {x = parent.position.x,y=parent.position.y}
  obj.target = self:nearbyPosition(parent.position)
  obj.owner = parent.owner
  obj.angle = math.random()*math.pi*2
  local tactions = {}
  for i,v in pairs(obj.actions or {}) do
    table.insert(tactions,self.actions[v])
  end
  for i,v in pairs(self.multi) do
    if obj[i] ~= nil then
      obj[i] = v
    end
  end
  obj.actions = tactions
  return obj
end

function mission:enter()

end

function mission:hasNextLevel()
  return love.filesystem.exists("levels/"..(self.level+1)..".lua")
end

function mission:nextLevel()

  self.jump_inform = false

  self.multi.collect = false
  local tobjects = {}
  for _,object in pairs(self.objects) do
    if collect ~= nil then
      object.collect = false
    end
    if object.owner == 0  then
      table.insert(tobjects,object)
    end
  end
  -- Removing things in lua pairs breaks things badly.
  self.objects = tobjects

  self.level = self.level + 1

  local level_data = require("levels/"..self.level)

  self.jump = level_data.jump and (1-level_data.jump)*self.jump_max or self.jump_max

  self.vn = level_data:intro()
  if disable_vn then
    self.vn._run = false
  end

  self.planets = {}
  for i = 1, 5 do
    self.planets[i] = {
      z = 0.1, -- paralax scrolling: the lower the Z, the slower the planets pan on camera
      x = math.random(0,love.graphics.getWidth())*1.5,
      y = math.random(0,love.graphics.getHeight())*1.5,
      size = math.random(32,64)/64,
      rotation = math.random(32,64)/5120,
      img = self.planet_images[math.random(#self.planet_images)],
      angle = math.random()*math.pi*2,
    }
  end

  if level_data.asteroid then
    for i = 1,level_data.asteroid*difficulty.mult.asteroid do
      local parent_object = {
        position = {
          x = self.level == 1 and math.random(0,love.graphics.getWidth()) or math.random(0,32*128),
          y = self.level == 1 and math.random(0,love.graphics.getHeight()) or math.random(0,32*128),
        },
      }
      local asteroid_object = self:build_object("asteroid",parent_object)
      table.insert(self.objects,asteroid_object)
    end
  end

  if level_data.scrap then
    for i = 1,level_data.scrap*difficulty.mult.scrap do
      local parent_object = {
        position = {
          x = self.level == 1 and math.random(0,love.graphics.getWidth()) or math.random(0,32*128),
          y = self.level == 1 and math.random(0,love.graphics.getHeight()) or math.random(0,32*128),
        },
      }
      local scrap_object = self:build_object("scrap",parent_object)
      table.insert(self.objects,scrap_object)
    end
  end

  if level_data.station then
    for i = 1,level_data.station*difficulty.mult.station do
      local parent_object = {
        position = {
          x = self.level == 1 and math.random(0,love.graphics.getWidth()) or math.random(0,32*128),
          y = self.level == 1 and math.random(0,love.graphics.getHeight()) or math.random(0,32*128),
        },
      }
      local station_object = self:build_object("station",parent_object)
      table.insert(self.objects,station_object)
    end
  end

  if level_data.enemy then
    for i = 1,level_data.enemy*difficulty.mult.enemy do
      local unsafe_x,unsafe_y = 0,0
      while unsafe_x < love.graphics.getWidth()+400 and unsafe_y < love.graphics.getHeight()+400 do
        unsafe_x,unsafe_y = math.random(0,32*128),math.random(0,32*128)
      end
      local parent_object = {
        position = {
          x = unsafe_x,
          y = unsafe_y,
        },
        owner = 1,
      }
      local enemy_object = self:build_object("enemy",parent_object)
      table.insert(self.objects,enemy_object)
    end
  end

  if level_data.jumpscrambler then
    for i = 1,level_data.jumpscrambler do
      local parent_object = {
        position = {
          x = self.level == 1 and math.random(0,love.graphics.getWidth()) or math.random(0,32*128),
          y = self.level == 1 and math.random(0,love.graphics.getHeight()) or math.random(0,32*128),
        },
        owner = 1,
      }
      local station_object = self:build_object("jumpscrambler",parent_object)
      table.insert(self.objects,station_object)
    end
  end


  if level_data.boss then
    for i = 1,level_data.boss do
      local unsafe_x,unsafe_y = 0,0
      while unsafe_x < love.graphics.getWidth()+400 and unsafe_y < love.graphics.getHeight()+400 do
        unsafe_x,unsafe_y = math.random(0,32*128),math.random(0,32*128)
      end
      local parent_object = {
        position = {
          x = unsafe_x,
          y = unsafe_y,
        },
        owner = 1,
      }
      local enemy_object = self:build_object("boss",parent_object)
      table.insert(self.objects,enemy_object)
    end

  end

  -- easter egg cat
  local cat_object = self:build_object("cat",{position={
    x = math.random(0,32*128),
    y = math.random(0,32*128),}})
  table.insert(self.objects,cat_object)

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
  self.camera.x = love.graphics.getWidth()/2
  self.camera.y = love.graphics.getHeight()/2
end


    -- Thanks Chris Nixon (ashlon23)!!! much love!

function mission:nearbyPosition(position)
  return {
    x = position.x + math.random(-128,128),
    y = position.y + math.random(-128,128),
  }
end

function mission:canAffordObject(object)
  for resource_type,cost in pairs(object.cost) do
    if self.resources[resource_type] < cost then
      return false
    end
  end
  return true
end

function mission:buyBuildObject(costs)
  local good = true
  for resource_type,cost in pairs(costs) do
    if self.resources[resource_type] < cost then
      good = false
      print("Insufficient "..resource_type.." [have: "..self.resources[resource_type].." need: "..cost.."]")
      if self.sfx.insufficient[resource_type] then
        playSFX(self.sfx.insufficient[resource_type])
      else
        playSFX(self.sfx.insufficient.funds)
      end
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

function mission:moveSelected(x,y,ox,oy)

  ox,oy = ox or 0,oy or 0

  local grid = {}
  local grid_size = 48
  for _,object in pairs(self.objects) do
    if not object.selected and object.owner == 0 then
      local sx = object.target and object.target.x or object.position.x
      local sy = object.target and object.target.y or object.position.y
      local gx,gy = math.floor(sx/grid_size),math.floor(sy/grid_size)
      grid[gx] = grid[gx] or {}
      grid[gx][gy] = object
    end
  end
  for _,object in pairs(self.objects) do
    if object.selected and object.owner == 0 then
      if object.collect ~= nil then
        object.collect = false
      end
      local range = 0
      local found = false
      while found == false do
        local rx,ry = x + math.random(-range,range),y + math.random(-range,range)
        local gx,gy = math.floor(rx/grid_size),math.floor(ry/grid_size)
        local tx,ty = gx*grid_size+ox,gy*grid_size+oy
        if tx > 0 and ty > 0 and tx < 128*32 and ty < 128*32 and
          (not grid[gx] or not grid[gx][gy]) then

          grid[gx] = grid[gx] or {}
          grid[gx][gy] = object
          object.target = {x=tx,y=ty}
          object.anim = 0.25
          object.target_object = nil
          playSFX(self.sfx.moving)
          found = true
          self.target_show = {
            x=self.camera.x+x-love.graphics.getWidth()/2,
            y=self.camera.y+y-love.graphics.getHeight()/2,
            anim=0.25
          }

        end
        range = range + 0.25
      end
    end
  end

end

function mission:mousepressed(x,y,b)
  if self.vn:getRun() then
    self.vn:next()
    return
  end
  if self:mouseInMiniMap() then
    if b == 2 then
      local mx,my,mw,mh = self:miniMapArea()
      local px,py = (x-mx)*32,(y-my)*32
      self:moveSelected(px,py)
    end
  elseif self:mouseInSelected() then
    local posx = math.floor((love.mouse.getX()-32)/(32+self:iconPadding()))+1
    local posy = -math.floor((love.mouse.getY()-love.graphics.getHeight()+32)/(32+self:iconPadding()))
    local row,col = 0,0
    for _,object in pairs(self.objects) do
      if object.selected then
        object.selected = false
        if col+1 == posx and row+1 == posy then
          object.selected = true
        end
        col = col + 1
        if col >= self.selected_row_max then
          col = 0
          row = row + 1
        end
      end
    end
  elseif self:mouseInActions() then
    local actions = self:getActions()
    local cobject = self:singleSelected()
    if actions then
      local pos = math.floor((love.mouse.getY()-32)/(32+self:iconPadding()))+1
      for ai,a in pairs(actions) do
        if ai == pos then
          if cobject then
            a.exe(cobject)
          else
            a.multi.exe(self.multi)
          end
        end
      end
    end
  else

    local ox,oy = self:getCameraOffset()
    local closest_object, closest_object_distance = self:findClosestObject(x+ox,y+oy)

    if b == 1 then
      if closest_object and closest_object_distance < 32 then
        if not love.keyboard.isDown("lshift") then
          for _,object in pairs(self.objects) do
            object.selected = false
          end
        end
        closest_object.selected = true
        closest_object.anim = 0.25
      else
        self.select_start = {x=x,y=y}
      end
    elseif b == 2 then

      if closest_object and closest_object_distance < 32 then

        for _,object in pairs(self.objects) do
          if object.selected and object.owner == 0 then
            object.target_object = closest_object
            object.target_object.anim = 0.25
            playSFX(self.sfx.moving)
          end
        end

      else

        local ox,oy = self:getCameraOffset()
        self:moveSelected(x,y,ox,oy)

      end

    end
  end
end

function mission:keypressed(key)
  if key == "escape" then
    if self.vn:getRun() then
      self.vn:stop()
    else
      libs.hump.gamestate.switch(states.pause)
      self.select_start = nil
    end
  else
    if self.vn:getRun() then
      self.vn:next()
      return
    end
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

function mission:getCameraOffset()
  return self.camera.x-love.graphics.getWidth()/2,self.camera.y-love.graphics.getHeight()/2
end

function mission:mousereleased(x,y,b)
  if self.vn:getRun() then return end
  if b == 1 then
    if self.select_start then
      for _,object in pairs(self.objects) do
        local ox,oy = self:getCameraOffset()
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

  libs.stars:draw(self.camera.x/2,self.camera.y/2)

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

    if object.work then
      love.graphics.setColor(self.colors.ui.secondary)
      local percent = (object.work.current or 0)/object.work.time
      libs.pcb(object.position.x,object.position.y,object.size*1.2,0.9,percent)
    end

    if object.selected then
      love.graphics.setColor(self.colors.ui.primary)
      love.graphics.circle("line",object.position.x,object.position.y,object.size)
    end

    if object.anim then
      love.graphics.setColor(255,255,255,255*object.anim/(object.anim_max or object.anim))
      love.graphics.circle("line",object.position.x,object.position.y,
        object.size+object.anim/object.anim_max*4)
    end

    local ship_color = {255,255,255}

    if object.health and object.health.current then
      local percent = object.health.current/object.health.max
      if (object.owner == 0 and percent < 1) or love.keyboard.isDown("lalt") then
        local bx,by,bw,bh = object.position.x-32,object.position.y+32,64,6
        love.graphics.setColor(0,0,0,127)
        love.graphics.rectangle("fill",bx,by,bw,bh)
        love.graphics.setColor(libs.healthcolor(percent))
        --love.graphics.rectangle("fill",bx+1,by+1,(bw-2)*percent,bh-2)
        local bw = 64/object.health.max*5
        for i = 1,object.health.max/5*percent do
          love.graphics.rectangle("fill",bx+bw*(i-1)+1,by+1,bw-1,bh-2)
        end
      end
      local hue_change = 0.5
      if percent < hue_change then
        local hue = 255*percent/hue_change
        ship_color = {255,hue,hue}
      end
    end

    love.graphics.setColor(self:ownerColor(object.owner))
    love.graphics.draw(self.objects_chevron,
      object.position.x,object.position.y,0,1,1,
      self.objects_chevron:getWidth()/2,self.objects_chevron:getHeight()/2)

    love.graphics.setColor(255,255,255)
    if object.incoming_bullets then
      for _,bullet in pairs(object.incoming_bullets) do
        love.graphics.draw(self.bullets.laser,bullet.x,bullet.y,bullet.angle,
          1,1,self.bullets.laser:getWidth()/2,self.bullets.laser:getHeight()/2)
      end
    end

    local object_variation = object.variation or 0
    local object_image = self.objects_image[object.type][object_variation]
    if object_image == nil then
      object_image = love.graphics.newImage("assets/objects/"..
        object.type..object_variation..".png")
      self.objects_image[object.type][object_variation] = object_image

      local object_icon = love.graphics.newImage("assets/objects/"..
        object.type..object_variation.."_icon.png")
      self.objects_icon[object.type][object_variation] = object_icon
    end
    love.graphics.setColor(ship_color)
    love.graphics.draw(object_image,
      object.position.x,object.position.y,
      object.angle or 0,1,1,object_image:getWidth()/2,object_image:getHeight()/2)
    love.graphics.setColor({255,255,255})

    if debug_mode then
      love.graphics.print(tostring(object),object.position.x,object.position.y)
    end

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

  self.fow:renderTo(function()
    love.graphics.clear()
    love.graphics.setColor(255,255,255)
    love.graphics.rectangle("fill",0,0,
      love.graphics.getWidth(),
      love.graphics.getHeight()
    )
    for _,object in pairs(self.objects) do
      if object.owner == 0 then
        local x = object.position.x-self.camera.x+love.graphics.getWidth()/2
        local y = object.position.y-self.camera.y+love.graphics.getHeight()/2

        if settings:read("fow_quality","img_canvas") == "img_canvas" then
          love.graphics.draw(self.fow_img,x,y,
            object.fow_rot,object.fow or 1,object.fow or 1,
            self.fow_img:getWidth()/2,
            self.fow_img:getHeight()/2)
        else
          love.graphics.setColor(0,0,0)
          love.graphics.circle("fill",x,y,512*(object.fow or 1))
          love.graphics.setColor(255,255,255)
        end
      end
    end
    for _,explosion in pairs(self.explosions) do
      local percent = 1 - explosion.dt/#self.explosion_images
      local fow_scale = (explosion.fow or 1)*percent
      love.graphics.setColor(255,255,255,percent*255)
      local x = explosion.x-self.camera.x+love.graphics.getWidth()/2
      local y = explosion.y-self.camera.y+love.graphics.getHeight()/2

      if settings:read("fow_quality","img_canvas") == "img_canvas" then
        love.graphics.draw(self.fow_img,x,y,
          explosion.fow_rot,fow_scale,fow_scale,
          self.fow_img:getWidth()/2,
          self.fow_img:getHeight()/2)
      else
        love.graphics.setColor(0,0,0)
        love.graphics.circle("fill",x,y,512*fow_scale)
        love.graphics.setColor(255,255,255)
      end
    end
  end)

  love.graphics.setBlendMode("subtract")
  love.graphics.setColor(255,255,255)
  love.graphics.draw(self.fow)
  love.graphics.setBlendMode("alpha")

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

  for rindex,r in pairs(self.resources_types) do
    local symbol
    if self.resources[r.."_delta"] < 0 then
      love.graphics.setColor(255,0,0)
      symbol = "▼"
    else
      love.graphics.setColor(0,255,0)
      symbol = "▲"
    end
    dropshadow(
      self.resources_types_formatted[rindex]..": "..
      math.floor(self.resources[r]).."/"..self.resources[r.."_cargo"]..
      " ["..symbol..math.floor(self.resources[r.."_delta"]+0.5).."]",
      32,128+64+18*rindex)
  end
  love.graphics.setColor(255,255,255)

  local font = love.graphics.getFont()
  dropshadowf("Level "..self.level,
    32,love.graphics.getHeight()-32-font:getHeight(),
    love.graphics.getWidth()-64,"right")

  if self.jump_active then
    love.graphics.setColor(0,0,0,255-255*self.jump_active/self.sfx_data.jump:getDuration())
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
    love.graphics.setColor(255,255,255)
  end

  if self.vn:getRun() then
    self.vn:draw()
  end

end

function mission:iconPadding()
  return 4
end

function mission:resize()
  self.fow = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
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

function mission:getActions()
  local cobject = self:singleSelected()
  local actions
  if cobject and cobject.actions then
    actions = cobject.actions
  else
    actions = {}
    for _,action in pairs(self.actions) do
      if action.multi then
        table.insert(actions,action)
      end
    end
  end
  return actions
end

function mission:drawActions()

  local cobject = self:singleSelected()
  for ai,a in pairs(self:getActions()) do
    local x,y = love.graphics.getWidth()-64,32+(ai-1)*(32+self:iconPadding())
    love.graphics.draw(self.icon_bg,x,y)

    --lol ternaries
    love.graphics.setColor(a.color and (
      cobject and a.color(cobject) or a.multi.color(self.multi)
    ) or {255,0,255,127})

    if a.hover then
      local r,g,b = love.graphics.getColor()
      love.graphics.setColor(r,g,b)
      local tobject = a.type and self.build[a.type]() or ""
      dropshadowf(cobject and a.tooltip(cobject) or a.multi.tooltip(self.multi),
        32,y+6,love.graphics.getWidth()-96-8,"right")
    end
    love.graphics.draw(self.action_icons[a.icon],x,y)
    love.graphics.setColor(255,255,255)
  end

end

function mission:drawSelected()
  local index = 0
  local row,col = 0,0
  for _,object in pairs(self.objects) do
    if object.selected then
      local x,y = col*(32+self:iconPadding())+32,love.graphics.getHeight()-32-32-row*(32+self:iconPadding())
      love.graphics.draw(self.icon_bg,x,y)
      index = index + 1
      local object_icon = self.objects_icon[object.type][object.variation or 0]
      local percent = object.health and object.health.current/object.health.max or 1
      love.graphics.setColor(libs.healthcolor(percent))
      love.graphics.draw(object_icon,x,y)
      love.graphics.setColor(255,255,255)
      col = col + 1
      if col >= self.selected_row_max then
        col = 0
        row = row + 1
      end
    end
  end
  local cobject = self:singleSelected()
  if cobject then
    dropshadow((cobject.display_name or "").." — "..(cobject.info or ""),64+8,love.graphics.getHeight()-64)
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
  local row,col = 0,0
  for _,object in pairs(self.objects) do
    if object.selected then
      col = col + 1
      if col >= self.selected_row_max then
        row = row + 1
        col = 0
      end
    end
  end
  -- NO UR A HACK
  local mrow = col == 0 and row or row+1
  local mcol = row>0 and self.selected_row_max or col
  return 32,love.graphics.getHeight()-32-mrow*(32+self:iconPadding()),
    mcol*(32+self:iconPadding()),
    mrow*(32+self:iconPadding())
end

function mission:mouseInActions()
  local x,y,w,h = self:actionArea()
  local mx,my = love.mouse.getPosition()
  return mx >= x and mx <= x+w and my >= y and my <= y+h
end

function mission:actionArea()
  local actions = self:getActions()
  if actions then
    local count = -1
    for ia,a in pairs(actions) do
      count = count + 1
    end
    return love.graphics.getWidth()-64,32,32,32+count*(32+self:iconPadding())
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

function mission:getObjectWithModifier(val)
  local ModifierObjects = {}
  for _,object in pairs(self.objects) do
    if object[val] then
      table.insert(ModifierObjects,object)
    end
  end
  return ModifierObjects
end

function mission:drawMinimap()
  local x,y,w,h = self:miniMapArea()
  love.graphics.draw(self.map_bg)
  love.graphics.setScissor(x-4,y-4,w+8,h+8)
  local scale = self:miniMapScale()
  for _,object in pairs(self.objects) do
    if object.owner == 0 then
      love.graphics.setColor(255,255,255,63)
      love.graphics.circle("fill",
        x+object.position.x/scale,y+object.position.y/scale,
        self.fow_img:getWidth()/scale/2*(object.fow or 1))
    end
  end
  for _,object in pairs(self.objects) do
    if object.minimap ~= false then
      love.graphics.setColor(self:ownerColor(object.owner))
      --love.graphics.points(x+object.position.x/scale,y+object.position.y/scale)
      love.graphics.rectangle("fill",
        x+object.position.x/scale,y+object.position.y/scale,2,2)
    end
  end
  love.graphics.setColor(self.colors.ui.primary)
  local cx,cy,cw,ch = (self.camera.x-love.graphics.getWidth()/2)/scale,(self.camera.y-love.graphics.getHeight()/2)/scale,love.graphics.getWidth()/scale,love.graphics.getHeight()/scale
  love.graphics.rectangle("line",x+cx,y+cy,cw,ch)


  love.graphics.setScissor()
  love.graphics.setColor(255,255,255)
end

function mission:update(dt)

  self.time = self.time + dt

  if cheat_operation_cwal then
    dt = dt * (love.keyboard.isDown("space") and 4 or 0.1)
  end
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

end

function mission:updateMission(dt)

  if self.jump_active then
    if self.sfx.jump:isPlaying() then
      self.jump_active = math.max(0,self.jump_active - dt*self.sfx_data.jump:getDuration())
    else
      self.jump_active = nil
      if self:hasNextLevel() then
        self.score:add("time",self.time)
        self.time = 0
        self:nextLevel()
      else
        libs.hump.gamestate.switch(states.win)
      end
    end
  end

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

  local player_ships = self:getObjectsByOwner(0)

  for _,object in pairs(self.objects) do

    if object.work then
      if object.work.current == nil then
        object.work.current = 0
      end
      object.work.current = object.work.current + dt
      if object.work.current >= object.work.time then
        object.work.callback(object)
        object.work = nil
      end
    end

    if object.rotate then
      object.angle = object.angle + object.rotate*dt
    end

    if object.crew_generate then
      local amount = object.crew_generate*dt
      self.score:add("born",amount)
      self.resources.crew = self.resources.crew + amount
      self.resources.crew_delta = self.resources.crew_delta + object.crew_generate
    end

    if object.jump and object.jump_process then
      self.jump = math.min(self.jump_max,math.max(0,self.jump - dt*object.jump))
      if self.jump <= 0 and self.jump_inform ~= true then
        self.jump_inform = true
        playSFX(self.sfx.jumpReady)
      end
    end

    if object.gravity_well then
      for _,other in pairs(self.objects) do
        if object ~= other then
          local distance = self:distance(object.position,other.position)
          if distance < object.gravity_well.range then
            local dx,dy = other.position.x-object.position.x,other.position.y-object.position.y
            local angle = math.atan2(dy,dx)+math.pi
            other.position.x = other.position.x + math.cos(angle)*dt*10
            other.position.y = other.position.y + math.sin(angle)*dt*10
          end
          if distance < 48 then
            if other.health then
              if other.health.current then
                other.health.current = math.max(0,other.health.current - object.gravity_well.damage*dt)
              end
            else
              other.remove_from_game = true
            end
          end
        end
      end
    end

    if object.owner == 0 then
      object.fow_rot = object.fow_rot and object.fow_rot + dt/60 or math.random()*math.pi*2
    end

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
          playSFX(self.sfx.shoot[bullet.sfx.destruct])
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
        playSFX(self.sfx.shoot[object.shoot.sfx.construct])
        table.insert(object.target_object.incoming_bullets,{
          speed = object.shoot.speed,
          damage = object.shoot.damage,
          sfx = object.shoot.sfx,
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

    if object.repair and object.health.current > 0 then
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

    if object.target_object then

      if self:distance(object.position,object.target_object.position) < 48 then

        -- takeover ships
        if object.takeover and object.target_object.pc ~= false and object.target_object.owner ~= 0 then
          local gotyou = false
          if object.target_object.health then
            local percent = object.target_object.health.current/object.target_object.health.max
            if percent < object.takeover then
              gotyou = true
            end
          else
            gotyou = true
          end
          if gotyou then
            self.score:add("takeover")
            if object.target_object.type == "cat" then
              self.score:add("egg")
            end
            object.target_object.owner = 0
            object.remove_from_game = true
            object.no_scrap_drop = true
            object.repair = false
            object.target_object.wander = nil
          end
        end

        -- mine ore from things with ore_supply
        if object.ore_gather and object.target_object.ore_supply then

          local amount = object.ore_gather*dt
          self.score:add("ore",amount)
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

        -- collect scrap from things with scrap_supply
        if object.scrap_gather and object.target_object.scrap_supply then

          local amount = object.scrap_gather*dt
          self.score:add("scrap")
          self.resources.material_delta = self.resources.material_delta + amount/dt
          if object.target_object.scrap_supply > amount then
            object.target_object.scrap_supply = object.target_object.scrap_supply - amount
            self.resources.material = self.resources.material + amount
          else
            self.resources.material = self.resources.material + object.target_object.scrap_supply
            object.target_object.scrap_supply = 0
          end
          loopSFX(self.sfx.salvaging)
        end

        -- collect crew from things with crew_supply
        if object.crew_gather and object.target_object.crew_supply then

          local amount = object.crew_gather*dt
          self.score:add("crew")
          self.resources.crew_delta = self.resources.crew_delta + amount/dt
          if object.target_object.crew_supply > amount then
            object.target_object.crew_supply = object.target_object.crew_supply - amount
            self.resources.crew = self.resources.crew + amount
          else
            self.resources.crew = self.resources.crew + object.target_object.crew_supply
            object.target_object.crew_supply = 0
          end
        end

      end --end of distance check

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

      if object.collect then

        for _,resource_type in pairs({"scrap","ore","crew"}) do
          if object[resource_type.."_gather"] then
            local modobjs = mission:getObjectWithModifier(resource_type.."_supply")
            if #modobjs > 0 then
              object.target_object = modobjs[math.random(#modobjs)]
            end
          end
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
      if object.speed then
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
    end

    if object.owner and object.owner ~= 0 and not object.wander then
      if self.jump > 0 then
        object.wander = {
          x = math.random(0,128*32),
          y = math.random(0,128*32),
        }
      else
        local target = player_ships[math.random(#player_ships)]
        object.wander = {
          x = target.position.x,
          y = target.position.y,
        }
      end
    end

    if object.speed then
      if object.wander then
        if not object.target and not object.target_object then
          local dx,dy = object.position.x-object.wander.x,object.position.y-object.wander.y
          object.angle = math.atan2(dy,dx)+math.pi
          object.position.x = object.position.x + math.cos(object.angle)*dt*object.speed*self.speed_mult/2
          object.position.y = object.position.y + math.sin(object.angle)*dt*object.speed*self.speed_mult/2
        end
        if self:distance(object.wander,object.position) < 32 then
          object.wander = nil
        end
      end
    end

  end -- end of object loop

  -- cleanup

  if #player_ships < 1 then
    libs.hump.gamestate.switch(states.lose)
  end

  for object_index,object in pairs(self.objects) do
    if (object.health and object.health.current and object.health.current <= 0) or
      (object.scrap_supply and object.scrap_supply <= 0) or
      (object.crew_supply and object.crew_supply <= 0) or
      (object.ore_supply and object.ore_supply <= 0) or
      object.remove_from_game then

      if object.cost and object.cost.material and not object.no_scrap_drop then
        local scrap_object = self:build_object("scrap",object)
        scrap_object.scrap_supply = object.cost.material*0.5
        scrap_object.owner = nil
        table.insert(self.objects,scrap_object)
      end

      if object.owner == 0 then
        self.score:add("lost")
      elseif object.owner == 1 then
        self.score:add("kill")
      elseif object.owner == nil then
      end

      table.remove(self.objects,object_index)

      table.insert(self.explosions,{
        x = object.position.x + math.random(-8,8),
        y = object.position.y + math.random(-8,8),
        angle = math.random()*math.pi*2,
        dt = 0,
        fow_rot = object.fow_rot,
        fow = object.fow or 1,
      })
      playSFX(self.objects_death_sfx[object.type])
    end

    if object.target_object and (
      (object.target_object.health and object.target_object.health.current <= 0) or
      (object.target_object.scrap_supply and object.target_object.scrap_supply <= 0 ) or
      (object.target_object.crew_supply and object.target_object.crew_supply <= 0 ) or
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

  for _,action in pairs(self.actions) do
    action.hover = false
  end

  if not self.select_start then

    if self:mouseInMiniMap() then
      if love.mouse.isDown(1) then
        local x,y,w,h = self:miniMapArea()
        local nx = (love.mouse.getX()-x)*self:miniMapScale()
        local ny = (love.mouse.getY()-y)*self:miniMapScale()

        self.camera:move(-self.camera.x + nx, -self.camera.y + ny)
        mission:clampCamera()
      end
    elseif self:mouseInSelected() then
      -- nop
    elseif self:mouseInActions() then
      local actions = self:getActions()
      if actions then
        local pos = math.floor((love.mouse.getY()-32)/(32+self:iconPadding()))+1
        for ai,a in pairs(actions) do
          if ai == pos then
            a.hover = true
          end
        end
      end
    else

      local left = love.keyboard.isDown("left","a") or
        love.mouse.getX() < love.graphics.getWidth()*self.camera.horizontal_mouse_move
      local right = love.keyboard.isDown("right","d") or
        love.mouse.getX() > love.graphics.getWidth()*(1-self.camera.horizontal_mouse_move)
      local up = love.keyboard.isDown("up","w") or
        love.mouse.getY() < love.graphics.getHeight()*self.camera.vertical_mouse_move
      local down = love.keyboard.isDown("down","s") or
        love.mouse.getY() > love.graphics.getHeight()*(1-self.camera.vertical_mouse_move)

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
      self:clampCamera()
    end

  end

end

function mission:clampCamera()
  local nx = math.max(self.camera.x,love.graphics.getWidth()/2)
  local ny = math.max(self.camera.y,love.graphics.getHeight()/2)
  nx = math.min(nx,128*self:miniMapScale()-love.graphics.getWidth()/2)
  ny = math.min(ny,128*self:miniMapScale()-love.graphics.getHeight()/2)
  self.camera.x = nx
  self.camera.y = ny
end

return mission
