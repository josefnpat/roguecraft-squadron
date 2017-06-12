local tree = {}

function tree.new(init)
  init = init or {}
  local self = {}

  self.loadData = tree.loadData
  self.saveData = tree.saveData

  self.loadGame = tree.loadGame
  self.saveGame = tree.saveGame

  self.getLevelData = tree.getLevelData

  return self
end

function tree:loadData()
  local raw = love.filesystem.read("assets/tree.json")
  self._data = libs.json.decode(raw)
end

function tree:saveData()
  -- No, you're a sandbox!
  local raw = libs.json.encode(self._data)
  local f,err = io.open("src/assets/tree.json","w+")
  f:write(raw)
  f:close()
end

function tree:loadGame()
  self._game = {}
end

function tree:saveGame()
end

function tree:getLevelData(name)
  if self._game[name] and self._game[name].level then
    return self._game[name].level,self.data[name].maxlevel
  elseif self._data[name] then
    return self._data[name].level,self.data[name].maxlevel
  else
    print("Warning: tree does not contain `"..tostring(name).."`")
    return 1,1
  end
end

return tree
