local level = {}

local game_over = false

level.id = "1"
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

  scope.end_mission_ship = server.createObject(self.storage,"dojeer_turret_large",2048,2048,self.badguy)
  scope.ship = server.createObject(self.storage,"fighter",-128,128,self.player)

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
      for i = 1,3 do
        local ship = server.createObject(self.storage,"fighter",0,0,self.player)
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
          local enemy = server.createObject(self.storage,"dojeer_scout",x*1024,y*1024,self.badguy)
          table.insert(scope.enemies,enemy)
        end
      end
    end,
  })

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Let's practice some shooting. Right mouse click on enemies to attack them.",
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
    text="I've jumped in a Command ship for you. Let's build a Habitat.",
    status="Build a Habitat.",
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
    hint=function()
      if states.client.actionpanel:showPanel() then
        return states.client.actionpanel
      end
    end,
  })

  scope.crew = 0
  scope.crew_target = 25

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="The habitats generate crew over time to make sure we have extra crew compliment. Collect "..scope.crew_target.." Crew.",
    status=function()
      return "Collect Crew. ("..scope.crew.."/"..scope.crew_target..")"
    end,
    icon=love.graphics.newImage("assets/actions/collect.png"),
    value=function()
      scope.crew = math.floor(self.player.resources["crew"])
      return scope.crew >= scope.crew_target,math.min(1,scope.crew/scope.crew_target)
    end,
    target=function()
      return scope.first_habitat
    end,
    hint=function()
      return states.client.resources.resourceBars["crew"]
    end,
    onComplete=function()
      self.player.resources["material"] = 400
    end,
  })

  scope.scrapper_count = 0

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="We're going to need a strong economy. Let's build some Scrappers.",
    status=function()
      return "Build four Scrappers ("..scope.scrapper_count.."/4)."
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
    hint=function()
      if states.client.actionpanel:showPanel() then
        return states.client.actionpanel
      end
    end,
  })

  scope.material = 0
  scope.material_target = 600

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Scrappers collect Material from Scrap that can be found on the map. Gather "..scope.material_target.." Material.",
    status=function()
      return "Gather Material. ("..scope.material.."/"..scope.material_target..")"
    end,
    icon=love.graphics.newImage("assets/actions/collect.png"),
    value=function()
      scope.material = math.floor(self.player.resources["material"])
      return scope.material >= scope.material_target,math.min(1,scope.material/scope.material_target)
    end,
    target=function()
      return scope.first_scrapper
    end,
    hint=function()
      return states.client.resources.resourceBars["material"]
    end,
    onComplete=function()
      for i = 1,2 do
        local ship = server.createObject(self.storage,"research",0,0,self.player)
        scope.first_research = scope.first_research or ship
        local t = math.pi*2*math.random()
        local r = 128
        local x = r*math.cos(t)
        local y = r*math.sin(t)
        libs.net.moveToTarget(server,ship,x,y,true)
      end
    end,
  })

  scope.research = 0
  scope.research_target = 20

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Research is generated by Research Facilities and Command ships. Gather "..scope.research_target.." Research.",
    status=function()
      return "Gather Research. ("..scope.research.."/"..scope.research_target..")"
    end,
    icon=love.graphics.newImage("assets/actions/collect.png"),
    value=function()
      scope.research = math.floor(self.player.resources["research"])
      return scope.research >= scope.research_target,math.min(1,scope.research/scope.research_target)
    end,
    target=function()
      return scope.first_research
    end,
    hint=function()
      return states.client.resources.resourceBars["research"]
    end,
  })

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Unlock the Civilian Drydock. Press R, select the Civilian Drydock, select Unlock.",
    status=function()
      return "Unlock Civilian Drydock."
    end,
    icon=love.graphics.newImage("assets/mp_objects/drydock/icons/1.png"),
    value=function()
      if libs.researchrenderer.isLoaded() then
        return libs.researchrenderer.isUnlocked(self.player,{type="drydock"})
      end
    end,
    hint=function()
      return states.client.buttonbar
    end,
  })

  scope.drydock_count = 0

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Let's expand our civilian building capacity. Build a Civilian Drydock.",
    status=function()
      return "Build a Civilian Drydock."
    end,
    icon=love.graphics.newImage("assets/mp_objects/drydock/icons/1.png"),
    value=function()
      local drydocks = server:findObjectsOfType("drydock")
      scope.first_drydock = drydocks[1]
      scope.drydock_count = #drydocks
      return scope.drydock_count >= 1,math.min(1,scope.drydock_count)
    end,
    target=function()
      return scope.command
    end,
    hint=function()
      if states.client.actionpanel:showPanel() then
        return states.client.actionpanel
      end
    end,
  })

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Unlock the Military Drydock. Press R, select the Military Drydock, select Unlock.",
    status=function()
      return "Unlock Military Drydock."
    end,
    icon=love.graphics.newImage("assets/mp_objects/advdrydock/icons/1.png"),
    value=function()
      if libs.researchrenderer.isLoaded() then
        return libs.researchrenderer.isUnlocked(self.player,{type="advdrydock"})
      end
    end,
    hint=function()
      return states.client.buttonbar
    end,
  })

  scope.advdrydock_count = 0

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Let's expand our military building capacity. Build a Military Drydock.",
    status=function()
      return "Build a Military Drydock."
    end,
    icon=love.graphics.newImage("assets/mp_objects/advdrydock/icons/1.png"),
    value=function()
      local advdrydock = server:findObjectsOfType("advdrydock")
      scope.first_advdrydock = advdrydock[1]
      scope.advdrydock_count = #advdrydock
      return scope.advdrydock_count >= 1,math.min(1,scope.advdrydock_count)
    end,
    target=function()
      return scope.command
    end,
    hint=function()
      if states.client.actionpanel:showPanel() then
        return states.client.actionpanel
      end
    end,
  })

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Let's build a small fleet of Battlestars. Press R, select the Battlestar, select Unlock.",
    status=function()
      return "Unlock Battlestar."
    end,
    icon=love.graphics.newImage("assets/mp_objects/combat/icons/1.png"),
    value=function()
      if libs.researchrenderer.isLoaded() then
        return libs.researchrenderer.isUnlocked(self.player,{type="combat"})
      end
    end,
    hint=function()
      return states.client.buttonbar
    end,
  })

  scope.combat_count = 0
  scope.combat_target = 3

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Let's expand our squadron. Build "..scope.combat_target.." Battlestars.",
    status=function()
      return "Build "..scope.combat_target.." Battlestars ("..scope.combat_count.."/"..scope.combat_target..")."
    end,
    icon=love.graphics.newImage("assets/mp_objects/combat/icons/1.png"),
    value=function()
      scope.combat_count = #server:findObjectsOfType("combat")
      return scope.combat_count >= scope.combat_target,math.min(1,scope.combat_count/scope.combat_target)
    end,
    target=function()
      return scope.first_advdrydock
    end,
    hint=function()
      if states.client.actionpanel:showPanel() then
        return states.client.actionpanel
      end
    end,
    onComplete=function()

      local enemy_fleet = {}
      table.insert(enemy_fleet,"dojeer_command")
      for i = 1,3 do
        table.insert(enemy_fleet,"dojeer_scout")
      end
      for i = 1,2 do
        table.insert(enemy_fleet,"dojeer_fighter")
      end
      for i = 1,1 do
        table.insert(enemy_fleet,"dojeer_combat")
      end

      for _,t in pairs(enemy_fleet) do
        local enemy = server.createObject(self.storage,t,2048,2048,self.badguy)
        table.insert(scope.final_enemies,enemy)
        libs.net.moveToTarget(server,enemy,0,0,true)
      end
    end,
  })

  scope.final_enemies = {}

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Here's your final. Let's get a wargame started. Use everything you learned to defeat the enemy.",
    status="Defeat the enemy.",
    icon=love.graphics.newImage("assets/actions/upgrade_damage.png"),
    value=function()
      if #scope.final_enemies == 0 then
        return false,0
      end
      local target_enemy,count_enemy = true,0
      for enemy_index,enemy in pairs(scope.final_enemies) do
        if enemy.health > 0 then
          target_enemy = false
          count_enemy = count_enemy + 1
        end
      end
      return target_enemy,1-count_enemy/#scope.final_enemies
    end,
    target=function()
      for _,enemy in pairs(scope.final_enemies) do
        if enemy.health > 0 then
          return enemy
        end
      end
    end,
  })

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="If you need further tips, check out the in game tips. Press T.",
    status="Check out the tips.",
    icon=love.graphics.newImage("assets/hud/buttonbar/tips.png"),
    value=function()
      if states.client.mptips:getActive() then
        scope.tips_seen = true
      else
        if scope.tips_seen then
          return true
        end
      end
      return false
    end,
    onComplete=function()
      server:addUpdate(scope.end_mission_ship,{remove=true},"delete_objects")
    end,
  })

end

return level
