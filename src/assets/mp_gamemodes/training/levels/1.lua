local level = {}

local game_over = false

level.id = "1"
-- level.next_level = "2"
-- level.victory = function()
--   return game_over
-- end
level.map = "training"

level.players_skel = {
  gen = libs.levelshared.gen.none,
}

level.players_config_skel = {
  team = 1,
}

level.ai_players = {
  {
    config = {
      ai = 1, -- ID
      team = 2,
    },
    gen = libs.levelshared.gen.none,
  },
}

function level:init(server)
  assert(server)
  self.storage = server.lovernet:getStorage()
  assert(self.storage)
  local users = server.lovernet:getUsers()
  for _,user in pairs(users) do
    if user.ai then
      self.badguy = user
    else
      self.player = user
    end
    if self.badguy and self.player then
      break
    end
  end
  assert(self.badguy)
  assert(self.player)

  -- Don't let the AI surrender
  self.badguy.ai:setSurrender(false)

  local scope = {}

  server.createObject(self.storage,"station_training",0,0,self.player)

  scope.end_mission_ship = server.createObject(self.storage,"turret_large",2048,2048,self.badguy)
  scope.ship = server.createObject(self.storage,"combat",-128,128,self.player)

  states.client.tutorial:clear()
  states.client.tutorial:setActive(true)

  scope.distance_traveled = 0
  scope.lcamera = {x=0,y=0}

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Are you there cadet? Move the camera either by moving your mouse to the edge of the screen or pressing WASD.",
    status="Move the camera.",
    icon=love.graphics.newImage("assets/actions/camera.png"),
    value=function()
      local camera = states.client.camera
      scope.distance_traveled = scope.distance_traveled + math.sqrt((scope.lcamera.x-camera.x)^2 + (scope.lcamera.y-camera.y)^2)
      scope.lcamera = {x=camera.x,y=camera.y}
      return scope.distance_traveled > 512,math.min(1,scope.distance_traveled/512)
    end,
  })

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Let's make sure your heads up display works correctly. Select your ship with left mouse button.",
    status="Select your ship.",
    icon=love.graphics.newImage("assets/actions/lmb.png"),
    value=function()
      local client_ship = libs.net.findObject(states.client.objects,scope.ship.index)
      return states.client.selection:isSelected(client_ship)
    end,
    target=scope.ship,
  })

  scope.last_ship_coord = {}
  scope.ship_move_count = 0

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Good. Now let's make sure that we can issue orders. Move your ship with right mouse button.",
    status="Issue move orders.",
    icon=love.graphics.newImage("assets/actions/rmb.png"),
    value=function()
      if scope.last_ship_coord.x ~= scope.ship.tx or scope.last_ship_coord.y ~= scope.ship.ty then
        scope.ship_move_count = scope.ship_move_count + 1
        scope.last_ship_coord = {x=scope.ship.tx,y=scope.ship.ty}
      end
      return scope.ship_move_count >= 5,math.min(1,scope.ship_move_count/5)
    end,
    onComplete=function()
      for i = 1,7 do
        local ship = server.createObject(self.storage,"combat",0,0,self.player)
        local t = math.pi*2*math.random()
        local r = 128
        local x = r*math.cos(t)
        local y = r*math.sin(t)
        libs.net.moveToTarget(server,ship,x,y,true)
      end
    end,
  })

  scope.enemies = {}

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Let's check that the heads up display can select a fleet. Select multiple ships by holding left mouse button.",
    status="Select multiple ships.",
    icon=love.graphics.newImage("assets/actions/lmb.png"),
    value=function()
      return #states.client.selection:getSelected() > 1
    end,
    onComplete=function()
      for x = -1,1,2 do
        for y = -1,1,2 do
          local enemy = server.createObject(self.storage,"dojeer_combat",x*1024,y*1024,self.badguy)
          table.insert(scope.enemies,enemy)
        end
      end
    end,
  })

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Let's get a wargame started. Right mouse click on enemies to attack them.",
    status="Destroy nearby enemies.",
    icon=love.graphics.newImage("assets/actions/rmb.png"),
    value=function()
      if #scope.enemies == 0 then
        return false,0
      end
      local target_enemy,count_enemy = true,0
      for enemy_index,enemy in pairs(scope.enemies) do
        if enemy.health > 0 then
          target_enemy = false
          count_enemy = count_enemy + 1
        end
      end
      return target_enemy,1-count_enemy/#scope.enemies
    end,
    target=function()
      for _,enemy in pairs(scope.enemies) do
        if enemy.health > 0 then
          return enemy
        end
      end
    end,
    onComplete=function()
      scope.command = server.createObject(self.storage,"command_training",0,0,self.player)
      self.player.resources["material"] = 100
      libs.net.moveToTarget(server,scope.command,128,128,true)
    end,
  })

  scope.habitat_count = 0

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="I've jumped in a command ship for you. Let's build a habitat.",
    status="Build a habitat.",
    icon=love.graphics.newImage("assets/mp_objects/habitat/icons/1.png"),
    value=function()
      local habitats = server:findObjectsOfType("habitat")
      scope.first_habitat = habitats[1]
      scope.habitat_count = #habitats
      return scope.habitat_count >= 1
    end,
    target=function()
      return scope.command
    end,
  })

  scope.crew = 0
  scope.crew_target = 25

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="The habitats generate crew over time to make sure we have extra crew compliment. Collect "..scope.crew_target.." crew.",
    status=function()
      return "Collect crew. ("..scope.crew.."/"..scope.crew_target..")"
    end,
    icon=love.graphics.newImage("assets/actions/collect.png"),
    value=function()
      scope.crew = math.floor(self.player.resources["crew"])
      return scope.crew >= scope.crew_target,math.min(1,scope.crew/scope.crew_target)
    end,
    target=function()
      return scope.first_habitat
    end,
    onComplete=function()
      self.player.resources["material"] = 400
    end,
  })

  scope.scrapper_count = 0

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="We're going to need a strong economy. Let's build some scrappers.",
    status=function()
      return "Build four scrappers ("..scope.scrapper_count.."/4)."
    end,
    icon=love.graphics.newImage("assets/mp_objects/salvager/icons/1.png"),
    value=function()
      local scrappers = server:findObjectsOfType("salvager")
      scope.first_scrapper = scrappers[1]
      scope.scrapper_count = #scrappers
      return scope.scrapper_count >= 4,math.min(1,scope.scrapper_count/4)
    end,
    target=function()
      return scope.command
    end,
  })

  scope.material = 0
  scope.material_target = 600

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Scrappers collect material from scrap that can be found on the map. Collect "..scope.material_target.." material.",
    status=function()
      return "Collect material. ("..scope.material.."/"..scope.material_target..")"
    end,
    icon=love.graphics.newImage("assets/actions/collect.png"),
    value=function()
      scope.material = math.floor(self.player.resources["material"])
      return scope.material >= scope.material_target,math.min(1,scope.material/scope.material_target)
    end,
    target=function()
      return scope.first_scrapper
    end,
    onComplete=function()
      server:addUpdate(scope.end_mission_ship,{remove=true},"delete_objects")
    end,
  })

end

return level
