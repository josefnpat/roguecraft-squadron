local level = {}

level.id = "1"
level.map = "random"

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

function level:generateInvader(type,damage_reduction)

  local mapsize = libs.net.mapSizes[self.storage.config.mapsize].value
  local mapoffset = mapsize + 1024
  local x = math.random(2) == 1 and mapoffset or -mapoffset
  local y = math.random(-mapoffset,mapoffset)
  if math.random(2) == 1 then
    x,y = y,x
  end
  local object = self.server.createObject(self.storage,type,x,y,self.invaders)
  object.drop_debris = false
  if damage_reduction < 1 then
    object.damage_reduction = damage_reduction
  end

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

  self.dt = 0
  -- Time before invasion starts
  self._offset = 60
  -- Difficulty for this game mode is in interval
  -- diff 1: 81 minutes to max
  -- diff 6: 14 miuntes 20 seconds to max
  self._interval = 240-(self.invaders.ai:getDiff()-1)*40
  -- Make AI as responsive as possible
  self.invaders.ai:setDiff(#libs.net.aiDifficulty)
  -- Don't let the AI surrender
  self.invaders.ai:setSurrender(false)
  -- Add an object so the AI never loses
  self.server.createObject(self.storage,"cat",0,0,self.invaders)

  local offset = self._offset
  local interval = self._interval
  level._spawn_types = {

    -- One per
    {object_type="dojeer_scout",      delay=offset+interval*0 ,t=1 },
    {object_type="dojeer_fighter",    delay=offset+interval*1 ,t=3 },
    {object_type="dojeer_combat",     delay=offset+interval*2 ,t=10},
    {object_type="dojeer_tank",       delay=offset+interval*3 ,t=5 },
    {object_type="dojeer_artillery",  delay=offset+interval*4 ,t=10},

    -- Two per
    {object_type="dojeer_scout",      delay=offset+interval*5 ,t=1 },
    {object_type="dojeer_fighter",    delay=offset+interval*6 ,t=3 },
    {object_type="dojeer_combat",     delay=offset+interval*7 ,t=10},
    {object_type="dojeer_tank",       delay=offset+interval*8 ,t=5 },
    {object_type="dojeer_artillery",  delay=offset+interval*9 ,t=10},

  }

  -- offset all deltas so that they don't spawn at exactly the same time
  for spawn_index,spawn in pairs(level._spawn_types) do
    spawn.dt = math.random()
  end

end

function level:update(dt,server)

  local count = 0
  for _,player in pairs(self.players) do
    count = count + player.count
  end
  if count == 0 then
    return
  end

  self.dt = self.dt + dt
  self.invaders.ai:setCurrentPocket(self.invaders.ai:getRandomPocket())
  -- for ever five intervals, we have a large interval. Include offset
  local current_interval = math.floor((self.dt-self._offset)/(self._interval*5))+1
  -- use math.max to create an initial 1 offset for the scaled spawner
  -- invert for ratio
  local damage_reduction = 1/math.max(1,current_interval)

  for _,spawn in pairs(self._spawn_types) do

    if spawn.delay then
      spawn.delay = spawn.delay - dt
      if spawn.delay <= 0 then
        spawn.delay = nil
        --print('new wave:',spawn.object_type)
      end
    else
      spawn.dt = spawn.dt + dt
      if spawn.dt >= spawn.t then
        spawn.dt = spawn.dt - spawn.t
        self:generateInvader(spawn.object_type,damage_reduction)
        --print('spawning:',spawn.object_type)
      end
    end

  end

end

return level
