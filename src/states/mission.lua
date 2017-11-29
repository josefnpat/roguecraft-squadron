local mission = {}


function mission:enter()
  states.menu.music.title:stop()
  states.menu.music.game:play()
end

--TODO: use init/enter correctly and refactor with newgame
function mission:init()

  self._ignoreBuild = {
    "build_asteroid",
    "build_blackhole",
    "build_cat",
    "build_scrap",
    "build_station",
    "build_enemy_fighter",
    "build_enemy_combat",
    "build_enemy_artillery",
    "build_enemy_tank",
    "build_enemy_boss",
    "build_enemy_miniboss",
    "build_enemy_jumpscrambler",
    "build_enemy_mine",
  }

  --TODO: NOT HACK
  self.tree = g_tree

  self.tree:loadData()
  self.tree:loadGame()

  self.enemy_types = {
    {type="enemy_fighter",q=4},
    {type="enemy_combat",q=1},
    {type="enemy_artillery",q=1},
    {type="enemy_tank",q=1},
    {type="enemy_miniboss",q=0.5},
  }

  self.hazard_types = {
    {type="enemy_mine",q=8},
  }

  self.gameover_t = 4

  self.time = 0

  -- defaults
  self.multi = {
    jump_process = true,
  }

  self.score = libs.score.new()
  self.score:define("kill","Killed","ship","ships",100)
  self.score:define("lost","Lost","ship","ships",100)
  self.score:define("material","Collected","scrap")
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
  self.fow_mult = 1.5

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
      basic = love.audio.newSource("assets/sfx/explosion.ogg","static"),
      asteroid = love.audio.newSource("assets/sfx/asteroid_death.ogg","static")
    },
    buildShip = love.audio.newSource("assets/sfx/build.ogg","static"),
    repairShip = love.audio.newSource("assets/sfx/repair.ogg","static"),
    workingShip = love.audio.newSource("assets/sfx/working.ogg","static"),
    refine = love.audio.newSource("assets/sfx/refine.ogg","static"),
    moving = {
      love.audio.newSource("assets/sfx/moving on my way.ogg","static"),
      love.audio.newSource("assets/sfx/moving ready.ogg","static"),
      love.audio.newSource("assets/sfx/moving yes commander.ogg","static"),
    },
    insufficient = {
      crew = love.audio.newSource("assets/sfx/voice insufficient crew.ogg","static"),
      material = love.audio.newSource("assets/sfx/voice insufficient material.ogg","static"),
      funds = love.audio.newSource("assets/sfx/voice insufficient funds.ogg","static"),
    },
    mining = love.audio.newSource("assets/sfx/mining.ogg","static"),
    salvaging = love.audio.newSource("assets/sfx/mining.ogg","static"),
    shoot = {
      laser = {
        love.audio.newSource("assets/sfx/laser_shoot0.ogg","static"),
        love.audio.newSource("assets/sfx/laser_shoot1.ogg","static"),
        love.audio.newSource("assets/sfx/laser_shoot2.ogg","static"),
        love.audio.newSource("assets/sfx/laser_shoot3.ogg","static"),
        love.audio.newSource("assets/sfx/laser_shoot4.ogg","static"),
      },
      collision = love.audio.newSource("assets/sfx/collision.ogg","static"),
    },
    jump = love.audio.newSource(self.sfx_data.jump,"static"),
    jumpReady = love.audio.newSource("assets/sfx/voice ready for jump.ogg","static"),
    warning = love.audio.newSource("assets/sfx/warning.ogg","static"),
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
    egg = love.graphics.newImage("assets/objects_icon/cat0.png"),
    upgrade = love.graphics.newImage("assets/actions/upgrade.png"),
    cta = love.graphics.newImage("assets/actions/cta.png"),
  }
  --TODO: add passive icons, such as attack/mine

  self.bullets = {
    laser = love.graphics.newImage("assets/bullets/laser.png"),
    missile = love.graphics.newImage("assets/bullets/missile.png"),
  }

  self.objects_chevron = love.graphics.newImage("assets/hud/chevron.png")
  self.target = love.graphics.newImage("assets/hud/target.png")

  self.map_bg = love.graphics.newImage("assets/hud/map_bg.png")
  self.icon_bg = love.graphics.newImage("assets/hud/icon_bg.png")
  self.camera = libs.hump.camera(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
  self.camera_speed = 500
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

  if self.tree:getLevelData("action_repair") > 0 then
    self.actions.repair = {
      icon = "repair",
      tooltip = function(object)
        return libs.i18n('mission.action.repair.pre',{
          repair_status=libs.i18n(object.repair and
            'mission.action.repair.enabled' or 'mission.action.repair.disabled')
        })
      end,
      color = function(object) return object.repair and {0,255,0} or {255,255,255} end,
      multi = {
        tooltip = function(object)
          return libs.i18n('mission.action.repair.multi',{
            repair_status=libs.i18n(object.repair and
              'mission.action.repair.enabled' or 'mission.action.repair.disabled')
          })
        end,
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
  end

  if self.tree:getLevelData("action_refine") > 0 then
    self.actions.refine = {
      icon = "refine",
      tooltip = function(object)
        return libs.i18n('mission.action.refine.pre',{
          refine_status=libs.i18n(object.repair and
            'mission.action.refine.enabled' or 'mission.action.refine.disabled')
        })
      end,
      color = function(object) return object.refine and {0,255,0} or {255,255,255} end,
      multi = {
        tooltip = function(object)
          return libs.i18n('mission.action.refine.multi',{
            refine_status=libs.i18n(object.repair and
              'mission.action.refine.enabled' or 'mission.action.refine.disabled')
          })
        end,
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
  end

  if self.tree:getLevelData("action_salvage") > 0 then
    self.actions.salvage = {
      icon = "salvage",
      tooltip = function(object)
        return libs.i18n('mission.action.salvage.pre',{salvage_value=90})
      end,
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
  end

  self.actions.jump = {
    icon = "jump",
    tooltip = function(object)
      if #self:getObjectWithModifier("jump_disable") > 0 then
        return libs.i18n('mission.action.jump.pre',{
          jump_status=libs.i18n('mission.action.jump.disabled')
        })
      end
      local percent = math.floor((1 - self.jump/self.jump_max)*1000)/10
      if self.jump <= 0 then
        return libs.i18n('mission.action.jump.pre',{
          jump_status=libs.i18n('mission.action.jump.ready')
        })
      else
        return libs.i18n('mission.action.jump.pre',{
          jump_status=libs.i18n('mission.action.jump.not_ready',{
            jump_percent=percent,
          })
        })
      end
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
      return libs.i18n('mission.action.jump_process.pre',{
        jump_process_status = libs.i18n(object.jump_process and
          'mission.action.jump_process.enabled' or
          'mission.action.jump_process.disabled')
      })
    end,
    color = function(object)
      return object.jump_process and {0,255,0} or {255,255,255}
    end,
    multi = {
      tooltip = function(object)
        return libs.i18n('mission.action.jump_process.pre',{
          jump_process_status = libs.i18n(object.jump_process and
            'mission.action.jump_process.enabled' or
            'mission.action.jump_process.disabled')
        })
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

  if self.tree:getLevelData("action_collect") > 0 then
    self.actions.collect = {
      icon = "collect",
      tooltip = function(object)
        return libs.i18n('mission.action.collect.pre',{
          collect_status=libs.i18n(object.collect and
            'mission.action.collect.enabled' or
            'mission.action.collect.disabled'
          )
        })
      end,
      color = function(object)
        return object.collect and {0,255,0} or {255,255,255}
      end,
      multi = {
        tooltip = function(object)
          return libs.i18n('mission.action.collect.multi',{
            collect_status=libs.i18n(object.collect and
              'mission.action.collect.enabled' or
              'mission.action.collect.disabled'
            )
          })
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
  end

  if self.tree:getLevelData("action_cta") > 0 then
    self.actions.cta = {
      icon = "cta",
      color = function(object) return {255,255,255} end,
      multi = {
        tooltip = function(object)
          return libs.i18n('mission.action.cta.pre')
        end,
        color = function(object)
          return #self:getObjectWithModifierByOwner("shoot",0) > 0 and {0,255,0} or {127,127,127}
        end,
        exe = function(data_object)
          for _,object in pairs(self.objects) do
            object.selected = object.owner == 0 and object.shoot
          end
        end,
      },
    }
  end

  self.actions.egg = {
    icon = "egg",
    tooltip = function(object)
      return libs.i18n('mission.action.egg.pre',{egg_value=100})
    end,
    color = function(object) return object.owner == 0 and {0,255,0} or {255,0,0} end,
    exe = function(object)
      if object.owner == 0 then
        object.remove_from_game = true
        self.resources.material = self.resources.material + 100
      end
    end,
  }

  self.upgrades = {}
  self.upgrades_lock = {}
  local upgrades_data = {}

  upgrades_data.speed = {
    display_name = libs.i18n('mission.upgrade.armor.name'),
    info = libs.i18n('mission.upgrade.armor.info'),
    max = 3,
    cost = {material=100},
    time = 10,
    mult = 1.5,
  }

  upgrades_data.armor = {
    display_name = libs.i18n('mission.upgrade.armor.name'),
    info = libs.i18n('mission.upgrade.armor.info'),
    max = 3,
    cost = {material=100},
    time = 10,
    mult = 1.5,
  }

  upgrades_data.damage = {
    display_name = libs.i18n('mission.upgrade.damage.name'),
    info = libs.i18n('mission.upgrade.damage.info'),
    max = 3,
    cost = {material=100},
    time = 10,
    mult = 1.5,
  }

  upgrades_data.refine = {
    display_name = libs.i18n('mission.upgrade.refine.name'),
    info = libs.i18n('mission.upgrade.refine.info'),
    max = 3,
    cost = {ore=100},
    time = 10,
    mult = 1.5,
  }

  upgrades_data.repair = {
    display_name = libs.i18n('mission.upgrade.refine.name'),
    info = libs.i18n('mission.upgrade.repair.info'),
    max = 3,
    cost = {material=100},
    time = 10,
    mult = 1.5,
  }

  upgrades_data.range = {
    display_name = libs.i18n('mission.upgrade.range.name'),
    info = libs.i18n('mission.upgrade.range.info'),
    max = 3,
    cost = {material=100},
    time = 10,
    mult = 1.5,
  }

  upgrades_data.build_time = {
    display_name = libs.i18n('mission.upgrade.build_time.name'),
    info = libs.i18n('mission.upgrade.build_time.info'),
    max = 3,
    cost = {material=100},
    time = 10,
    mult = 1.5,
  }

  upgrades_data.fow = {
    display_name = libs.i18n('mission.upgrade.fow.name'),
    info = libs.i18n('mission.upgrade.fow.info'),
    max = 3,
    cost = {material=100},
    time = 10,
    mult = 1.5,
  }

  upgrades_data.jump = {
    display_name = libs.i18n('mission.upgrade.jump.name'),
    info = libs.i18n('mission.upgrade.jump.info'),
    max = 3,
    cost = {material=100},
    time = 10,
    mult = 1.5,
  }

  upgrades_data.crew = {
    display_name = libs.i18n('mission.upgrade.crew.name'),
    info = libs.i18n('mission.upgrade.crew.info'),
    max = 3,
    cost = {material=100},
    time = 10,
    mult = 1.5,
  }

  upgrades_data.salvage = {
    display_name = libs.i18n('mission.upgrade.salvage.name'),
    info = libs.i18n('mission.upgrade.salvage.info'),
    max = 3,
    cost = {material=100},
    time = 10,
    mult = 1.5,
  }

  upgrades_data.mining = {
    display_name = libs.i18n('mission.upgrade.mining.name'),
    info = libs.i18n('mission.upgrade.mining.info'),
    max = 3,
    cost = {material=100},
    time = 10,
    mult = 1.5,
  }


  for upgrade_type,upgrade in pairs(upgrades_data) do

    local upgrade_string = "upgrade_"..upgrade_type

    local level,levelmax = self.tree:getLevelData(upgrade_string)
    if level > 0 then

      self.action_icons[upgrade_string] = love.graphics.newImage("assets/actions/"..upgrade_string..".png")

      self.upgrades[upgrade_type] = 0
      self.actions[upgrade_string] = {
        icon = upgrade_string,
        tooltip = function(object)
          if self.upgrades_lock[upgrade_type] and self.upgrades_lock[upgrade_type] ~= object then
            return libs.i18n('mission.upgrade_status.blocked_by_other',{
              upgrade_current=upgrade.display_name
            })
          elseif object.work then
            return libs.i18n('mission.upgrade_status.blocked',{
              upgrade_current=upgrade.display_name
            })
          elseif self.upgrades[upgrade_type] < upgrade.max then
            local newcost = self:multCost(upgrade.cost,upgrade.mult,self.upgrades[upgrade_type])
            return libs.i18n('mission.upgrade_status.ready',{
              upgrade_name = upgrade.display_name,
              upgrade_level_current = self.upgrades[upgrade_type],
              upgrade_level_max = upgrade.max,
              upgrade_cost = self:makeCostString(newcost),
            }) .."\n" .. upgrade.info
          else
            return libs.i18n('mission.upgrade_status.max',{
              upgrade_name=upgrade.display_name
            })
          end
        end,
        color = function(object)
          if self.upgrades_lock[upgrade_type] and self.upgrades_lock[upgrade_type] ~= object then
            return {127,127,127}
          elseif object.work then
            return {255,255,0}
          elseif self.upgrades[upgrade_type] < upgrade.max then
            local newcost = self:multCost(upgrade.cost,upgrade.mult,self.upgrades[upgrade_type])
            return self:canAffordObject({cost=newcost}) and {0,255,0} or {127,127,127}
          else
            return {127,127,127}
          end
        end,
        exe = function(object)
          if object.work or self.upgrades_lock[upgrade_type] then
            -- TODO: add queue
            -- research already being upgraded
          else
            self.upgrades_lock[upgrade_type] = object
            local newcost = self:multCost(upgrade.cost,upgrade.mult,self.upgrades[upgrade_type])
            if self.upgrades[upgrade_type] < upgrade.max and self:buyBuildObject(newcost) then
              --TODO
              --playSFX(self.sfx.researchStarted)
              object.work = {
                time = cheat_operation_cwal and 0.1 or upgrade.time*(1+(self.upgrades[upgrade_type]*upgrade.mult)),
                callback = function(object)
                  self.upgrades[upgrade_type] = self.upgrades[upgrade_type] + 1
                  self.upgrades_lock[upgrade_type] = nil
                  --TODO
                  --playSFX(self.sfx.researchComplete)
                end,
              }
            end
          end
        end,
      }
    end
  end

  self.build = {}
  for i,v in pairs(self.object_types) do
    self.build[v] = require("assets.objects_data."..v)
  end

  for objtype,objbuildfn in pairs(self.build) do

    local build_name = "build_"..objtype

    local level,levelmax = 0,0
    if not self:ignoreBuild(build_name) then
      level,levelmax = self.tree:getLevelData(build_name)
    end

    if level and level > 0 then
      self.action_icons[build_name] =
        love.graphics.newImage("assets/objects_icon/"..objtype.."0.png")
      self.actions[build_name] = {
        type = objtype,
        icon = "build_"..objtype,
        color = function(object)
          if object.work then
            return {255,255,0}
          else
            local tobject = self.build[objtype]()
            return self:canAffordObject(tobject) and {0,255,0} or {127,127,127}
          end
        end,
        tooltip = function(object)
          if object.work then
            return libs.i18n('mission.build_status.blocked',{
              build_current = object.work.build_type
            })
          else
            local tobject = self.build[objtype]()
            return libs.i18n('mission.build_status.ready',{
              build_name = libs.i18n('mission.object.'..tobject.type..'.name'),--tobject.display_name,
              build_cost = self:makeCostString(tobject.cost),
            }) .. "\n" .. libs.i18n('mission.object.'..tobject.type..'.info')
          end
        end,
        exe = function(object)
          if object.work == nil then
            local tobject = self.build[objtype]()
            if self:buyBuildObject(tobject.cost) then
              --TODO
              --playSFX(self.sfx.shipStarted)
              object.work = {
                build_type = objtype,
                time = cheat_operation_cwal and 0.1 or tobject.build_time*(1-(self.upgrades.build_time or 0)*0.1),
                callback = function(object)
                  local object = self:build_object(objtype,object)
                  table.insert(self.objects,object)
                  playSFX(self.sfx.buildShip)
                end,
              }
            end
          else
            -- TODO: add queue
            -- unit already being built
          end
        end,
      }
    end
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
  table.insert(self.objects,self:build_object("blackhole",{position={x=love.graphics.getWidth(),y=love.graphics.getHeight()}}))
  --]]
  local start_command = self:build_object("command",{position=self.start.position,owner=0})
  start_command.health.current = start_command.health.max*9/10
  table.insert(self.objects,start_command)
  table.insert(self.objects,self:build_object("jump",{position=self.start.position,owner=0}))
  --table.insert(self.objects,self:build_object("habitat",{position=self.start.position,owner=0}))

end -- END OF INIT

function mission:ignoreBuild(name)
  for i,v in pairs(self._ignoreBuild) do
    if v == name then
      return true
    end
  end
  return false
end

function mission:multCost(cost,mult,level)
  local newcost = {}
  for i,v in pairs(cost) do
    newcost[i] = v*(1+mult*level)
  end
  return newcost
end

function mission:build_object(object_name,parent)
  local obj = self.build[object_name]()
  obj.display_name = obj.display_name or libs.i18n('mission.object.'..obj.type..'.name')
  obj.info = obj.info or libs.i18n('mission.object.'..obj.type..'.info')
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

function mission:hasNextLevel()
  return love.filesystem.exists("assets/levels/"..(self.level+1)..".lua")
end

function mission:nextLevel()

  self.gameover_dt = nil

  self.spawn_new_wave = 0
  self.spawn_wave_t = 120

  self.notif = libs.notif.new()

  self.jump_inform = false

  self.multi.collect = false
  local tobjects = {}
  for _,object in pairs(self.objects) do
    object.target = nil
    object.target_object = nil
    object.wander = nil
    if object.collect ~= nil then
      object.collect = false
    end
    if object.owner == 0  then
      table.insert(tobjects,object)
    end
  end
  -- Removing things in lua pairs breaks things badly.
  self.objects = tobjects

  self.level = self.level + 1

  self.notif:add("Level "..self.level)

  local level_data = require("assets/levels/"..self.level)

  self.tutorial = nil
  if settings:read("tutorial") and level_data.make_tutorial then
    self.tutorial = level_data.make_tutorial()
  end

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
    for i = 1,level_data.station do
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
    self:spawnEnemy(level_data.enemy*difficulty.mult.enemy)
    self:spawnHazard(level_data.enemy*difficulty.mult.enemy)
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
      local station_object = self:build_object("enemy_jumpscrambler",parent_object)
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
      local enemy_object = self:build_object("enemy_boss",parent_object)
      table.insert(self.objects,enemy_object)
    end
  end

  if level_data.blackhole then
    for i = 1,level_data.blackhole do
      local parent_object = {
        position = {
          x = self.level == 1 and math.random(0,love.graphics.getWidth()) or math.random(0,32*128),
          y = self.level == 1 and math.random(0,love.graphics.getHeight()) or math.random(0,32*128),
        },
      }
      local bh_object = self:build_object("blackhole",parent_object)
      table.insert(self.objects,bh_object)
    end
  end

  for i = 1,15 do
    local parent_object = {
      position = {
        x = math.random(0,32*128),
        y = math.random(0,32*128),
      },
    }
    local cloud_object = self:build_object("cloud",parent_object)
    table.insert(self.objects,cloud_object)
  end

  -- easter egg cat
  local cat_object = self:build_object("cat",{position={
    x = math.random(0,32*128),
    y = math.random(0,32*128),}})
  table.insert(self.objects,cat_object)

  self:regroupByOwner(0,128)
end

function mission:spawnEnemy(q,overridex,overridey)
  local skip = false
  for i = 1,q do
    if skip then
      skip = false
    else
      local unsafe_x,unsafe_y = 0,0
      while unsafe_x < love.graphics.getWidth()+400 and unsafe_y < love.graphics.getHeight()+400 do
        unsafe_x,unsafe_y = math.random(0,32*128),math.random(0,32*128)
      end
      local parent_object = {
        position = {
          x = overridex or unsafe_x,
          y = overridey or unsafe_y,
        },
        owner = 1,
      }
      local enemy = self.enemy_types[self.level == 2 and 1 or math.random(#self.enemy_types)]
      if enemy.q == 0.5 then
        skip = true
        local enemy_object = self:build_object(enemy.type,parent_object)
        table.insert(self.objects,enemy_object)
      else
        for i = 1,enemy.q do
          local enemy_object = self:build_object(enemy.type,parent_object)
          table.insert(self.objects,enemy_object)
        end
      end

    end
  end
end

function mission:spawnHazard(q,overridex,overridey)
  for i = 1,q do
    local unsafe_x,unsafe_y = 0,0
    while unsafe_x < love.graphics.getWidth()+400 and unsafe_y < love.graphics.getHeight()+400 do
      unsafe_x,unsafe_y = math.random(0,32*128),math.random(0,32*128)
    end
    local parent_object = {
      position = {
        x = overridex or unsafe_x,
        y = overridey or unsafe_y,
      },
      owner = 1,
    }
    local hazard = self.hazard_types[self.level == 2 and 1 or math.random(#self.hazard_types)]
    local hazard_object = self:build_object(hazard.type,parent_object)
    table.insert(self.objects,hazard_object)
  end
end

function mission:regroupByOwner(owner,scatter)
  --scatter is amount of pixels they move randomly after regroup
  for _,object in pairs(self:getObjectsByOwner(owner)) do
    object.position.x = self.start.position.x + math.random(-scatter,scatter)
    object.position.y = self.start.position.y + math.random(-scatter,scatter)
    object.target = nil
    object.target_object = nil
    object.wander = nil
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
      --print("Insufficient "..resource_type.." [have: "..self.resources[resource_type].." need: "..cost.."]")
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
          object.wander = nil
          playSFX(self.sfx.moving)
          found = true
          self.target_show = {
            x=self.camera.x+x-love.graphics.getWidth()/2,
            y=self.camera.y+y-love.graphics.getHeight()/2,
            anim=0.25
          }

        end
        range = range + 8
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
  elseif self.tutorial and self.tutorial:inArea() then
    --nop
  elseif self:mouseInSelected() then

    local posx = math.floor(
      (love.mouse.getX()-self:windowPadding())/
        (self:iconSize()+self:iconPadding())
      )+1
    local posy = -math.floor(
      (love.mouse.getY()-love.graphics.getHeight()+self:windowPadding())/
        (self:iconSize()+self:iconPadding())
      )
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
      local pos = math.floor(
        (love.mouse.getY()-self:windowPadding())/
          (self:iconSize()+self:iconPadding())
        )+1
      for ai,a in pairs(actions) do
        if ai == pos then
          if cobject then
            a.exe(cobject)
            a.pressed = 1
          else
            a.multi.exe(self.multi)
            a.pressed = 1
          end
        end
      end
    end
  else -- mouse in playing area

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
        if self.last_selected == closest_object then
          self.last_selected = nil
          self.last_selected_timeout = nil

          for _,object in pairs(self.objects) do
            if not love.keyboard.isDown("lshift") then
              object.selected = false
            end
            if object.owner == 0 and object.type == closest_object.type then
              object.selected = true
            end
          end

        else
          self.last_selected = closest_object
          self.last_selected_timeout = 0.5 -- default for windows
        end
      else
        self.select_start = {x=x,y=y}
      end
    elseif b == 2 then
      if closest_object and closest_object_distance < 32 then
        for _,object in pairs(self.objects) do
          if object.selected and object.owner == 0 then
            if closest_object.owner == 0 then
              object.wander = {target=closest_object}
              object.target= nil
              object.target_object = nil
            else
              object.target_object = closest_object
              object.wander = nil
            end
            closest_object.anim = 0.25
            playSFX(self.sfx.moving)
          end
        end
      else
        local ox,oy = self:getCameraOffset()
        self:moveSelected(x,y,ox,oy)
      end
    end -- end of b == 2
  end -- end of mouse in playing area
end

function mission:keypressed(key)
  if cheat and key == "n" then self.level = self.level + 1 end
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

function mission:shortestAngle(c,t)
  return (t-c+math.pi)%(math.pi*2)-math.pi
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
      libs.pcb(object.position.x,object.position.y,object.size*1.5,0.75,percent,self.time)
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
        local bx,by,bw,bh = object.position.x-32,object.position.y+object.size,64,6
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
        local image = self.bullets[bullet.image]
        love.graphics.draw(image,bullet.x,bullet.y,bullet.angle,
          1,1,image:getWidth()/2,image:getHeight()/2)
      end
    end

    local object_variation = object.variation or 0
    local object_image = self.objects_image[object.type][object_variation]
    if object_image == nil then
      object_image = love.graphics.newImage("assets/objects/"..
        object.type..object_variation..".png")
      self.objects_image[object.type][object_variation] = object_image

      local object_icon = love.graphics.newImage("assets/objects_icon/"..
        object.type..object_variation..".png")
      self.objects_icon[object.type][object_variation] = object_icon
    end
    love.graphics.setColor(ship_color)
    love.graphics.draw(object_image,
      object.position.x,object.position.y,
      object.shown_angle or 0,1,1,object_image:getWidth()/2,object_image:getHeight()/2)
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

        -- don't forget minimap
        local fow = self.fow_mult*(object.fow or 1)*(1+(self.upgrades.fow or 0)*0.25)

        if settings:read("fow_quality") == "img_canvas" then
          love.graphics.draw(self.fow_img,x,y,
            object.fow_rot,fow,fow,
            self.fow_img:getWidth()/2,
            self.fow_img:getHeight()/2)
        else
          love.graphics.setColor(0,0,0)
          love.graphics.circle("fill",x,y,512*fow)
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

      if settings:read("fow_quality") == "img_canvas" then
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

  dropshadow(libs.i18n('mission.level',{
    level=self.level,
    max_level=8,
  }),self:windowPadding(),128+32+32+self:windowPadding())

  local sindex = 1
  for rindex,r in pairs(self.resources_types) do
    if self.resources[r.."_cargo"] > 0 then
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
        self:windowPadding(),128+32+32+self:windowPadding()+18*(sindex))
      sindex = sindex + 1
    end
  end
  love.graphics.setColor(255,255,255)

  if self.tutorial then self.tutorial:draw() end

  self.notif:draw()

  if self.jump_active then
    love.graphics.setColor(0,0,0,255-255*self.jump_active/self.sfx_data.jump:getDuration())
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
    love.graphics.setColor(255,255,255)
  end

  if self.vn:getRun() then self.vn:draw() end

  if self.gameover_dt then
    local percent = self.gameover_dt / self.gameover_t
    love.graphics.setColor(0,0,0,255*percent)
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
    love.graphics.setColor(255,255,255)
  end

end

function mission:iconPadding()
  return 4
end

function mission:iconSize()
  return 32
end

function mission:windowPadding()
  return 64
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
    actions = cobject.owner == 0 and cobject.actions or {}
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
    local x = love.graphics.getWidth()-self:iconSize()-self:windowPadding()
    local y = self:windowPadding()+(ai-1)*(self:iconSize()+self:iconPadding())

    local alpha = 255
    if a.pressed then
      alpha = 191+math.cos(a.pressed*math.pi*2)*64
    end

    local r,g,b = love.graphics.getColor()
    love.graphics.setColor(r,g,b,alpha)

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
        self:iconSize(),y+6,
        love.graphics.getWidth()-self:iconSize()*2-self:windowPadding()-8,"right")
    end

    local r,g,b = love.graphics.getColor()
    love.graphics.setColor(r,g,b,alpha)

    love.graphics.draw(self.action_icons[a.icon],x,y)
    love.graphics.setColor(255,255,255)
  end

end

function mission:drawSelected()
  local index = 0
  local row,col = 0,0
  for _,object in pairs(self.objects) do
    if object.selected then
      local x = col*(self:iconSize()+self:iconPadding())+self:windowPadding()
      local y = love.graphics.getHeight()-self:windowPadding()-self:iconSize()-
        row*(self:iconSize()+self:iconPadding())
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
    self.camera:attach()
    dropshadowf((cobject.display_name or "").." — "..(cobject.info or ""),
      cobject.position.x+cobject.size,
      cobject.position.y+cobject.size,
      320,"left")
    self.camera:detach()
  end
end

function mission:miniMapArea()
  return 32+self:windowPadding(),32+self:windowPadding(),128,128
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
  return self:windowPadding(),
    love.graphics.getHeight()-self:windowPadding()-mrow*(self:iconSize()+self:iconPadding()),
    mcol*(self:iconSize()+self:iconPadding()),
    mrow*(self:iconSize()+self:iconPadding())
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
    return love.graphics.getWidth()-self:iconSize()-self:windowPadding(),
      self:windowPadding(),
      self:iconSize(),
      self:iconSize()+count*(self:iconSize()+self:iconPadding())
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

function mission:getObjectWithModifierByOwner(mod,own)
  local ModifierObjects = {}
  for _,object in pairs(self.objects) do
    if object[mod] and object.owner == own then
      table.insert(ModifierObjects,object)
    end
  end
  return ModifierObjects
end

function mission:getObjectIntersectionQuery(queries)
  local foundObjects = {}
  for _,object in pairs(self.objects) do
    local valid = true
    for query_index,query in pairs(queries) do
      if query == "not_nil" then
        if object[query_index] == nil then
          valid = false
        end
      else
        if object[query_index] ~= query then
          valid = false
        end
      end
    end
    if valid then
      table.insert(foundObjects,object)
    end
  end
  return foundObjects
end

function mission:drawMinimap()
  local x,y,w,h = self:miniMapArea()
  love.graphics.draw(self.map_bg,self:windowPadding(),self:windowPadding())
  love.graphics.setScissor(x-4,y-4,w+8,h+8)
  local scale = self:miniMapScale()
  for _,object in pairs(self.objects) do
    if object.owner == 0 then
      love.graphics.setColor(255,255,255,63)

      -- don't forget canvas mask
      local fow = self.fow_mult*(object.fow or 1)*(1+(self.upgrades.fow or 0)*0.25)

      love.graphics.circle("fill",
        x+object.position.x/scale,y+object.position.y/scale,
        self.fow_img:getWidth()/scale/2*fow)
    end
  end
  for _,object in pairs(self.objects) do
    if object.minimap ~= false then
      love.graphics.setColor(self:ownerColor(object.owner))
      --love.graphics.points(x+object.position.x/scale,y+object.position.y/scale)
      love.graphics.rectangle("fill",
        x+object.position.x/scale,y+object.position.y/scale,2,2)
    end
    if object.in_combat then
      love.graphics.setColor(255,0,0)
      love.graphics.circle("line",
        x+object.position.x/scale,
        y+object.position.y/scale,
        6+math.sin(love.timer.getTime()*4))
    end
  end
  love.graphics.setColor(self.colors.ui.primary)
  local cx = (self.camera.x-love.graphics.getWidth()/2)/scale
  local cy = (self.camera.y-love.graphics.getHeight()/2)/scale
  local cw = love.graphics.getWidth()/scale
  local ch = love.graphics.getHeight()/scale
  love.graphics.rectangle("line",x+cx,y+cy,cw,ch)


  love.graphics.setScissor()
  love.graphics.setColor(255,255,255)
end

function mission:update(dt)

  self.time = self.time + dt

  if cheat_operation_cwal then
    dt = dt * (love.keyboard.isDown("space") and 4 or 1)
  end
  if cheat then
    for _,resource in pairs(self.resources_types) do
      self.resources[resource] = math.huge
    end
  end

  if love.keyboard.isDown("space") then
    local avgx,avgy,avgc = 0,0,0
    for _,object in pairs(self.objects) do
      if object.selected then
        avgx = avgx + object.position.x
        avgy = avgy + object.position.y
        avgc = avgc + 1
      end
    end
    if avgc > 0 then
      avgx,avgy = avgx/avgc,avgy/avgc
      self.camera.x = love.graphics.getWidth()/2+avgx
      self.camera.y = love.graphics.getHeight()/2+avgy
      self.camera.x,self.camera.y = avgx,avgy
    end
  end

  local game_music_vol = 1
  if not self.vn:getRun() then
    if self.tutorial then self.tutorial:update(dt) end
    self:updateMission(dt)
    self.notif:update(dt)
  else
    self.vn:update(dt)
    game_music_vol = 0.25
  end
  if states.menu.music then
    states.menu.music.title:setVolume(settings:read("music_vol")*game_music_vol)
    states.menu.music.game:setVolume(settings:read("music_vol")*game_music_vol)
  end

  if not love.window.hasFocus() then
    libs.hump.gamestate.switch(states.pause)
    self.select_start = nil
  end

  local ox,oy = self:getCameraOffset()
  local mx,my = love.mouse.getPosition()
  local c, cod = self:findClosestObject(mx+ox,my+oy)
  if cod < 32 then
    if c.owner == 0 then
      libs.cursor.change("player")
    elseif c.owner == 1 then
      libs.cursor.change("enemy")
    else
      libs.cursor.change("neutral")
    end
  else
    libs.cursor.change("default")
  end

end

function mission:updateMission(dt)

  if self.jump == 0 and self.level > 1 then
    self.spawn_new_wave = self.spawn_new_wave + dt
    if self.spawn_new_wave > self.spawn_wave_t then
      self.spawn_new_wave = self.spawn_new_wave - self.spawn_wave_t
      self.spawn_wave = (self.spawn_wave or 0) + 1

      self.notif:add(libs.i18n('mission.notification.enemy_reinforcements'),self.sfx.warning)

      -- TODO replace with trig omg wtf
      unsafe_x,unsafe_y = 0,0
      while unsafe_x >= 0 and unsafe_x <= 128*32 and
        unsafe_y >= 0  and unsafe_y <= 128*32 do
        unsafe_x = math.random(-32,128+32)*32
        unsafe_y = math.random(-32,128+32)*32
      end

      self:spawnEnemy(self.spawn_wave,unsafe_x,unsafe_y)
    end
  end


  if self.last_selected_timeout then
    self.last_selected_timeout = self.last_selected_timeout - dt
    if self.last_selected_timeout <= 0 then
      self.last_selected_timeout = nil
      self.last_selected = nil
    end
  end

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
        states.gameover.win = true
        libs.hump.gamestate.switch(states.gameover)
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

  -- First Pass (value construction)
  for _,object in pairs(self.objects) do

    if object.wander and object.wander.x then
      object.wander.x = math.max(4,math.min(128*32-4,object.wander.x))
      object.wander.y = math.max(4,math.min(128*32-4,object.wander.y))
    end

    if object.target then
      object.target.x = math.max(4,math.min(128*32-4,object.target.x))
      object.target.y = math.max(4,math.min(128*32-4,object.target.y))
    end

    if object.owner and object.owner == 0 then
      for _,resource in pairs(self.resources_types) do
        if object[resource] then
          self.resources[resource.."_cargo"] = self.resources[resource.."_cargo"] + object[resource]
        end
      end
    end
  end

  -- Second Pass
  for _,object in pairs(self.objects) do

    if object.in_combat then
      if self.player_in_combat == nil then
        self.notif:add(libs.i18n('mission.notification.enemy_engage'),self.sfx.warning)
      end
      self.player_in_combat = 1
      object.in_combat = object.in_combat - dt
      if object.in_combat <= 0 then
        object.in_combat = nil
      end
    end

    if object.shown_angle == nil then
      object.shown_angle = object.angle
    else
      local sa = self:shortestAngle(object.shown_angle,object.angle)
      object.shown_angle = object.shown_angle + sa*dt*4
    end

    if object.work then
      loopSFX(self.sfx.workingShip)
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
      local amount = object.crew_generate*dt*(1+(self.upgrades.crew or 0)*0.25)
      self.score:add("born",amount)
      self.resources.crew = self.resources.crew + amount
      self.resources.crew_delta = self.resources.crew_delta + amount/dt
    end

    if object.jump and object.jump_process then
      self.jump = math.min(self.jump_max,
        math.max(0,
          self.jump - dt*object.jump*(1+(self.upgrades.jump or 0)*0.1)))
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
                other.in_combat = 1
                if other.repair ~= nil then
                  other.repair = false
                end
              end
            else
              other.remove_from_game = true
            end
          end
        end
      end
    end

    if object.detonate then
      for _,other in pairs(self.objects) do
        if object ~= other and other.health and object.owner ~= other.owner then
          local distance = self:distance(object.position,other.position)
          if distance < object.detonate.range then
            other.health.current = math.max(0,other.health.current-object.detonate.damage)
            object.remove_from_game = true
          end
        end
      end
    end

    if object.slow then
      for _,other in pairs(self.objects) do
        if object ~= other and other.speed then
          local distance = self:distance(object.position,other.position)
          if distance < object.size then
            other.apply_slow = object.slow
          end
        end
      end
    end

    if object.apply_slow then
      object.apply_slow = object.apply_slow + dt
      if object.apply_slow >= 1 then
        object.apply_slow = nil
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
          -- yo momma is a ternary
          local damage = object.owner == 0 and
            (bullet.damage*(1-(self.upgrades.armor or 0)*0.1)) or
            (bullet.damage*(1+(self.upgrades.damage or 0)*0.1))

          object.health.current = math.max(0,object.health.current-damage)
          object.in_combat = 1
          if object.repair ~= nil then
            object.repair = false
          end
          table.remove(object.incoming_bullets,bullet_index)
          loopSFX(self.sfx.shoot[bullet.sfx.destruct])
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
      -- don't forget the range for movement
      local newrange = object.owner == 0 and object.shoot.range*(1+(self.upgrades.range or 0)*0.1) or object.shoot.range
      if object.shoot.reload <= 0 and object.target_object and
        object.target_object.owner ~= object.owner and object.target_object.health and
        self:distance(object.position,object.target_object.position) < newrange then

        object.shoot.reload = object.shoot.reload_t
        object.target_object.incoming_bullets = object.target_object.incoming_bullets or {}
        loopSFX(self.sfx.shoot[object.shoot.sfx.construct],0.5)
        table.insert(object.target_object.incoming_bullets,{
          speed = object.shoot.speed+math.random(0,16),
          damage = object.shoot.damage,
          image = object.shoot.image or "laser",
          sfx = object.shoot.sfx,
          x = object.position.x+math.random(-object.size,object.size),
          y = object.position.y+math.random(-object.size,object.size),
          angle = object.angle,
        })

      end
    end

    if object.refine and object.material_gather then
      local amount = object.material_gather*dt*(1+(self.upgrades.refine or 0)*0.1)
      local remain = self.resources.material_cargo - self.resources.material
      if amount > remain then
        amount = remain
      end
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

      local amount_to_repair = math.min(
        (object.health.max - object.health.current),
        object.health.max/10*(1+(self.upgrades.repair or 0)*0.25)
      )*dt

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

        -- Resource collection
        for resource_type,dat in pairs({
          material = {
            sfx=self.sfx.mining,
            upgrade="mining",
          },
          ore = {
            sfx=self.sfx.salvaging,
            upgrade="salvage",
          },
          crew = {
          },
        }) do
          local igather = resource_type .. "_gather"
          local isupply = resource_type .. "_supply"
          local idelta = resource_type .. "_delta"
          local icargo = resource_type .. "_cargo"
          if object[igather] and object.target_object[isupply] then
            local upgrade = dat.upgrade and ((self.upgrades[dat.upgrade] or 0)*0.25) or 0
            local amount = object[igather]*dt*(1+upgrade)
            if self.resources[resource_type] ~= self.resources[icargo] then
              if amount + self.resources[resource_type] > self.resources[icargo] then
                amount = self.resources[icargo] - self.resources[resource_type]
              end
              self.score:add(resource_type)
              self.resources[idelta] = self.resources[idelta] + amount/dt
              if object.target_object[isupply] > amount then
                object.target_object[isupply] = object.target_object[isupply] - amount
                self.resources[resource_type] = self.resources[resource_type] + amount
              else
                self.resources[resource_type] = self.resources[resource_type] + object.target_object[isupply]
                object.target_object[isupply] = 0
              end
              if dat.sfx then
                loopSFX(dat.sfx)
              end
            else
              self.notif:add(libs.i18n('mission.notification.cargo_full'))
              object.target_object = nil
              object.collect = false
            end
          end
        end

      end --end of distance check

      if object.target_object then

        if object.target_object.health and object.target_object.health.current <= 0 then
          object.target_object = nil
          object.target = nil
        else
          object.target = {
            x=object.target_object.position.x,
            y=object.target_object.position.y,
          }
        end

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

        for _,resource_type in pairs({"material","ore","crew"}) do
          if object[resource_type.."_gather"] then
            local modobjs = mission:getObjectWithModifier(resource_type.."_supply")
            table.sort(modobjs,function(a,b)
              return self:distance(object.position,a.position) <
                self:distance(object.position,b.position)
            end)
            if #modobjs > 0 then
              local index = math.random(1,math.floor(#modobjs/10)+1)
              object.target_object = modobjs[index]
            else
              object.collect = false
            end
          end
        end

      end

    end

    if object.target then
      local distance = self:distance(object.position,object.target)
      local range = 4
      if object.target_object then
        if object.shoot and object.target_object.owner ~= object.owner then
          -- don't forget the range for shooting
          range = object.owner == 0 and object.shoot.range*(1+(self.upgrades.range or 0)*0.1) or object.shoot.range
        else
          range = 48
        end
      end
      if object.speed then
        if distance > range then
          local speed = object.owner == 0 and object.speed*(1+(self.upgrades.speed or 0)*0.1) or object.speed
          speed = speed * (object.apply_slow or 1)
          if object.target.speed_mult then
            speed = speed * object.target.speed_mult
          end
          if self:isTurning(object) then
            speed = 0
          end
          local dx,dy = object.position.x-object.target.x,object.position.y-object.target.y
          object.angle = math.atan2(dy,dx)+math.pi
          object.position.x = object.position.x + math.cos(object.angle)*dt*speed*self.speed_mult
          object.position.y = object.position.y + math.sin(object.angle)*dt*speed*self.speed_mult
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
        if target then
          object.wander = {
            x = target.position.x,
            y = target.position.y,
          }
        end
      end
    end

    if object.speed then
      if object.wander then
        if not object.target and not object.target_object then

          local dist
          if object.wander.target then
            dist = self:distance(object.position,object.wander.target.position)
          else
            dist = self:distance(object.position,object.wander)
          end
          if dist < object.size*4 then
            -- I'm not sure how I feel about this ...
            object.target = {
              x = object.position.x + math.random(-128*2,128*2),
              y = object.position.y + math.random(-128*2,128*2),
              speed_mult = 0.25,
            }
          else
            local dx,dy
            local wander_speed = object.owner == 0 and 1 or 0.5
            if object.wander.target then
              dx = object.position.x-object.wander.target.position.x
              dy = object.position.y-object.wander.target.position.y
            else
              dx,dy = object.position.x-object.wander.x,object.position.y-object.wander.y
            end
            if self:isTurning(object) then
              wander_speed = 0
            end
            object.angle = math.atan2(dy,dx)+math.pi
            object.position.x = object.position.x + math.cos(object.angle)*dt*object.speed*self.speed_mult*wander_speed
            object.position.y = object.position.y + math.sin(object.angle)*dt*object.speed*self.speed_mult*wander_speed
          end

        end
      end
    end

  end -- end of object loop

  -- cleanup

  if self.player_in_combat then
    self.player_in_combat = self.player_in_combat - dt
    if self.player_in_combat <= 0 then
      self.player_in_combat = nil
    end
  end

  if #player_ships < 1 then
    self.gameover_dt = self.gameover_dt or 0
    self.gameover_dt = self.gameover_dt + dt
    if self.gameover_dt >= self.gameover_t then
      states.gameover.win = false
      libs.hump.gamestate.switch(states.gameover)
    end
  end

  for object_index,object in pairs(self.objects) do
    if (object.health and object.health.current and object.health.current <= 0) or
      (object.material_supply and object.material_supply <= 0) or
      (object.crew_supply and object.crew_supply <= 0) or
      (object.ore_supply and object.ore_supply <= 0) or
      object.remove_from_game then

      if object.cost and object.cost.material and not object.no_scrap_drop then
        local scrap_object = self:build_object("scrap",object)
        scrap_object.material_supply = object.cost.material*0.5
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
      (object.target_object.material_supply and object.target_object.material_supply <= 0 ) or
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
    if action.pressed then
      action.pressed = action.pressed - dt*4
      if action.pressed <= 0 then
        action.pressed = nil
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
        mission:clampCamera()
      end
    elseif self.tutorial and self.tutorial:inArea() then
      -- nop
    elseif self:mouseInSelected() then
      -- nop
    elseif self:mouseInActions() then
      local actions = self:getActions()
      if actions then
        local pos = math.floor(
          (love.mouse.getY()-self:windowPadding())/
            (self:iconSize()+self:iconPadding())
          )+1
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
        dx = -self.camera_speed*dt*settings:read("camera_speed")
      end
      if right then
        dx = self.camera_speed*dt*settings:read("camera_speed")
      end
      if up then
        dy = -self.camera_speed*dt*settings:read("camera_speed")
      end
      if down then
        dy = self.camera_speed*dt*settings:read("camera_speed")
      end

      self.camera:move(dx,dy)
      self:clampCamera()
    end

  end

end

function mission:isTurning(object)
  return math.abs(object.angle%math.pi-object.shown_angle%math.pi) > 0.2
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
