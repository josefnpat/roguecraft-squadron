local level = {}

local game_over = false

level.id = "1"
-- level.next_level = "2"
level.victory = function()
  return game_over
end
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

  self.server = server
  assert(self.server)
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

  self.server.createObject(self.storage,"cat",0,0,self.player)
  local ship = self.server.createObject(self.storage,"combat",128,128,self.player)

  states.client.tutorial:clear()
  states.client.tutorial:setActive(true)

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Are you there cadet?\n\nMove the camera either by moving your mouse to the edge of the screen or pressing WASD.",
    status="Move the camera.",
    value=function()
      local camera = states.client.camera
      return math.sqrt(camera.x^2 + camera.y^2) > 256
    end,
  })

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Let's make sure your heads up display works correctly.\n\nSelect your ship with left mouse button.",
    status="Select your ship.",
    value=function()
      local client_ship = libs.net.findObject(states.client.objects,ship.index)
      return states.client.selection:isSelected(client_ship)
    end,
    target=ship,
  })

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Good. Now let's make sure that we can issue orders.\n\nMove your ship with right mouse button.",
    status=function()
      return "Issue move order."
    end,
    value=function()
      return ship.tx and ship.ty
    end,
    onComplete=function()
      for i = 1,7 do
        local x = math.random(-128,128)
        local y = math.random(-128,128)
        self.server.createObject(self.storage,"combat",x,y,self.player)
      end
    end,
  })

  local enemies = {}

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Let's check that the heads up display can select a fleet.\n\nSelect multiple ships by holding left mouse button.",
    status="Select multiple ships.",
    value=function()
      return #states.client.selection:getSelected() > 1
    end,
    onComplete=function()
      for x = -1,1,2 do
        for y = -1,1,2 do
          local enemy = self.server.createObject(self.storage,"combat",x*1024,y*1024,self.badguy)
          table.insert(enemies,enemy)
        end
      end
    end,
  })

  states.client.tutorial:addObjective(libs.tutorialobjective.new{
    text="Let's get a wargame started.\n\nRight mouse click on enemies to attack them.",
    status="Destroy nearby enemies.",
    value=function()
      if #enemies == 0 then
        return false,0
      end
      local target_enemy,count_enemy = true,0
      for enemy_index,enemy in pairs(enemies) do
        if enemy.health > 0 then
          target_enemy = false
          count_enemy = count_enemy + 1
        end
      end
      return target_enemy,1-count_enemy/#enemies
    end,
    target=function()
      for _,enemy in pairs(enemies) do
        if enemy.health > 0 then
          return enemy
        end
      end
    end,
    onComplete=function()
      game_over = true
    end
  })
end

return level
