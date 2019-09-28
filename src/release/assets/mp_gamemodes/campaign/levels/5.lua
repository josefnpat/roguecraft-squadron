local level = {}

level.id = "5"
level.name = "Chapter 5:\nThe End of the Beginning"
level.next_level = "6"
level.victory = libs.levelshared.team_2_and_3_defeated
level.research_reward = 50

level.players_skel = {
  gen = libs.levelshared.gen.campaign_ruby,
}

level.players_config_skel = {
  team = 1,
}

level.ai_players = {
  {
    config = {
      ai = 1, -- ID
      team = 1,
      diff = 1, -- difficulty
      race = 1,
    },
    gen = libs.levelshared.gen.none,
  },
  {
    config = {
      ai = 2, -- ID
      team = 2,
      diff = 4, -- difficulty
      race = 2,
    },
    gen = libs.levelshared.gen.dojeer,
  },
  {
    config = {
      ai = 3, -- ID
      team = 2,
      diff = 1, -- difficulty
      race = 2,
    },
    gen = libs.levelshared.gen.none,
  },
  {
    config = {
      ai = 4, -- ID
      team = 2,
      diff = 1, -- difficulty
      race = 2,
    },
    gen = libs.levelshared.gen.none,
  },
}

function level:generateInvader(type)

  local mapsize = libs.net.mapSizes[self.storage.config.mapsize].value
  local mapoffset = mapsize + 1024
  local x = math.random(2) == 1 and mapoffset or -mapoffset
  local y = math.random(-mapoffset,mapoffset)
  if math.random(2) == 1 then
    x,y = y,x
  end
  local object = self.server.createObject(self.storage,type,x,y,self.invaders)
  object.drop_debris = false

  libs.net.moveToTarget(
    self.server,
    object,
    math.random(-mapsize,mapsize),
    math.random(-mapsize,mapsize),
    true)

end

function level:init(server)

  self.server = server
  assert(self.server)
  self.storage = server.lovernet:getStorage()
  assert(self.storage)
  local users = server.lovernet:getUsers()
  self.players = {}
  for _,user in pairs(users) do
    if user.ai then
      self.invaders = user
    else
      table.insert(self.players,user)
    end
  end
  assert(self.invaders)
  assert(#self.players>0)

  self.invasion = nil
  self.nuke = nil
  self.invasion_t = 10
  self.invasion_dt = self.invasion_t

end

-- hack incoming:
-- For some reason, the id doesn't match the invaders' id
-- so instead we figure out what isn't neutral and ins't a player
function level:belongsToHuman(object)
  for _,player in pairs(self.players) do
    if object.user == player.id then
      return true
    end
  end
  return false
end

function level:update(dt,server)

  local count = 0
  for _,player in pairs(self.players) do
    count = count + player.count
  end
  if count == 0 then
    return
  end

  local aicount = 0
  for _,object in pairs(self.storage.objects) do
    if object.user and not self:belongsToHuman(object) then
      aicount = aicount + 1
    end
  end
  if aicount == 0 then
    return
  end

  if aicount < 3 then
    if not self.invasion then
      self.invasion_player_count = math.max(3,math.floor(count/2))
    end
    self.invasion = true
  end

  if self.invasion then

    self.invasion_dt = self.invasion_dt + dt
    if self.invasion_dt > self.invasion_t then
      self.invasion_dt = 0
      for i = 1,5 do
        self:generateInvader("dojeer_scout")
        self:generateInvader("dojeer_fighter")
        self:generateInvader("dojeer_combat")
        self:generateInvader("dojeer_tank")
        self:generateInvader("dojeer_artillery")
        self:generateInvader("dojeer_capital")
      end
    end

    if count < self.invasion_player_count then
      if not self.nuke then
        for _,object in pairs(self.storage.objects) do
          if object.user and not self:belongsToHuman(object) then
            self.server:addUpdate(object,{remove=true},"delete_objects")
            object.remove = true
          end
        end
      end
      self.nuke = true
    end
  end

end

level.intro = function()
  return "Level 5 Prelude"
end

level.outro = function()
  return "Level 5 Complete"
end

return level
