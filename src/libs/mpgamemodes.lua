local mpgamemodes = {}

function mpgamemodes.load(loadAssets)
  mpgamemodes._gamemodes = {}
  mpgamemodes._dir = "assets/mp_gamemodes/"
  for _,filename in pairs(file.getAllDirectoryItems(mpgamemodes._dir)) do
    local gamemode = require(filename)
    if loadAssets then
      gamemode.image = love.graphics.newImage(filename.."/image.png")
    end
    gamemode.dir = filename
    table.insert(mpgamemodes._gamemodes,gamemode)
  end
  table.sort(mpgamemodes._gamemodes,function(a,b)
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
  self.getCurrentLevelData = mpgamemodes.getCurrentLevelData

  self._currentGamemode = nil
  self._currentLevel = nil
  self._currentLevelData = nil

  return self
end

function mpgamemodes:getGamemodes()
  return mpgamemodes._gamemodes
end

function mpgamemodes:getGamemodeById(id)
  for _,v in pairs(mpgamemodes._gamemodes) do
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

function mpgamemodes:getCurrentLevelData()
  return self._currentLevelData
end

return mpgamemodes
