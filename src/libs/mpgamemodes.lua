local mpgamemodes = {}

function mpgamemodes.load(loadAssets)
  mpgamemodes._allGamemodes = {}
  mpgamemodes._dir = "assets/mp_gamemodes/"
  for _,filename in pairs(file.getAllDirectoryItems(mpgamemodes._dir)) do
    local gamemode = require(filename)
    if loadAssets then
      gamemode.image = love.graphics.newImage(filename.."/image.png")
    end
    gamemode.dir = filename
    table.insert(mpgamemodes._allGamemodes,gamemode)
  end
  table.sort(mpgamemodes._allGamemodes,function(a,b)
    return a.weight < b.weight
  end)
end

function mpgamemodes.new(init)
  init = init or {}
  local self = {}

  self.getGamemodes = mpgamemodes.getGamemodes
  self.getGamemodeById = mpgamemodes.getGamemodeById
  self.getCurrentGamemode = mpgamemodes.getCurrentGamemode
  self.setCurrentGamemode = mpgamemodes.setCurrentGamemode
  self.getCurrentLevel = mpgamemodes.getCurrentLevel
  self.setCurrentLevel = mpgamemodes.setCurrentLevel
  self.loadCurrentLevel = mpgamemodes.loadCurrentLevel
  self.getAllLevelsLoaded = mpgamemodes.getAllLevelsLoaded
  self.unlockLevel = mpgamemodes.unlockLevel
  self.getCumulativeResearchReward = mpgamemodes.getCumulativeResearchReward
  self.getCurrentLevelData = mpgamemodes.getCurrentLevelData

  self._currentGamemode = nil
  self._currentLevel = nil
  self._startLevel = nil
  self._currentLevelData = nil

  self._gamemodes = {}
  for _,gamemode in pairs(mpgamemodes._allGamemodes) do

    local add_to_modes = true
    if gamemode.single_player_only then
      add_to_modes = game_singleplayer
    end
    if gamemode.multi_player_only then
      add_to_modes = not game_singleplayer
    end

    if add_to_modes then
      table.insert(self._gamemodes,gamemode)
    end

  end

  return self
end

function mpgamemodes:getGamemodes()
  return self._gamemodes
end

-- this function can be called without reference to the object as well
function mpgamemodes:getGamemodeById(id)
  for _,v in pairs(self._gamemodes or self._allGamemodes) do
    if v.id == id then
      return v
    end
  end
end

function mpgamemodes:getCurrentGamemode()
  return self._currentGamemode
end

function mpgamemodes:setCurrentGamemode(mode)
  assert(type(mode)=="table")
  self._currentGamemode = mode
  self._currentLevel = mode.start_level
  self._startLevel = mode.start_level
end

function mpgamemodes:getCurrentLevel()
  assert(self._currentLevel)
  return self._currentLevel
end

function mpgamemodes:setCurrentLevel(level)
  assert(type(level)=="string")
  self._currentLevel = level
end

function mpgamemodes:loadCurrentLevel()
  self._currentLevelData = require(self._currentGamemode.dir.."/levels/"..self._currentLevel)
end

function mpgamemodes:getAllLevelsLoaded()

  local gamemodes_save = settings:read("gamemodes")
  local gamemode_save = gamemodes_save[self._currentGamemode.id]
  local unlock_level = gamemode_save and gamemode_save.unlock or self._startLevel

  local levels = {}
  local current_level = self._startLevel
  local found_unlock_level = false
  while current_level do
    local level = require(self._currentGamemode.dir.."/levels/"..current_level)
    level.unlocked = not found_unlock_level
    if unlock_level == current_level then
      found_unlock_level = true
    end
    table.insert(levels,level)
    current_level = level.next_level
  end
  return levels
end

function mpgamemodes:unlockLevel(unlockLevel)

  local current_level = self._startLevel

  local found_unlock_level = false
  local found_current_level = false

  while current_level do
    local level = require(self._currentGamemode.dir.."/levels/"..current_level)
    if found_unlock_level and level.unlocked then
      unlockLevel = level
    end
    if unlockLevel.id == level.id then
      found_unlock_level = true
    end
    current_level = level.next_level
  end

  local gamemodes_save = settings:read("gamemodes")
  gamemodes_save[self._currentGamemode.id] = gamemodes_save[self._currentGamemode.id] or {}
  gamemodes_save[self._currentGamemode.id].unlock = unlockLevel.id
  settings:write(gamemodes_save)

end

function mpgamemodes:getCumulativeResearchReward()
  local total = 0
  local current_level = self._startLevel
  while current_level do
    local level = require(self._currentGamemode.dir.."/levels/"..current_level)
    total = total + (level.research_reward or 0)
    if self._currentLevel == current_level then
      return total
    end
    current_level = level.next_level
  end
  return total
end

function mpgamemodes:getCurrentLevelData()
  return self._currentLevelData
end

return mpgamemodes
