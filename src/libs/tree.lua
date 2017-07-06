local tree = {}

function tree.new(init)
  init = init or {}
  local self = {}

  self.loadData = tree.loadData
  self.saveData = tree.saveData

  self.loadGame = tree.loadGame
  self.saveGame = tree.saveGame

  self.getLevelData = tree.getLevelData
  self.incrementLevel = tree.incrementLevel

  self:loadData()
  self:loadGame()

  return self
end

function tree:loadData()
  local raw = love.filesystem.read("assets/tree.json")
  self._data = libs.json.decode(raw)
  for i,v in pairs(self._data) do
    assert(v.desc)
    assert(v.name)
    assert(v.info)
    assert(v.title)
  end
end

function tree:saveData()
  -- No, you're a sandbox!
  local raw = libs.json.encode(self._data)
  local f,err = io.open("src/assets/tree.json","w+")
  f:write(raw)
  f:close()
end

function tree:loadGame()
  self._levels = settings:read("tree_levels")
end

function tree:saveGame()
  settings:write("tree_levels",self._levels)
end

function tree:getLevelData(name)
  if self._levels[name] then
    return self._levels[name],self._data[name].maxlevel
  elseif self._data[name] and self._data[name].level then
    return self._data[name].level,self._data[name].maxlevel
  else
    print("Warning: tree does not contain `"..tostring(name).."`")
    return debug_mode and 1,1 or 0,1
  end
end

function tree:incrementLevel(name)
  self._levels[name] = (self._levels[name] or 0) + 1
end

return tree
