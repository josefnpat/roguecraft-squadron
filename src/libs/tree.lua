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
  os.execute("cat src/assets/tree.json | python -mjson.tool > /tmp/tree.json")
  os.execute("cat /tmp/tree.json > src/assets/tree.json")

end

function tree:loadGame()
  self._game = {}
end

function tree:saveGame()
end

function tree:getLevelData(name)
  if self._game[name] and self._game[name].level then
    return self._game[name].level,self._data[name].maxlevel
  elseif self._data[name] then
    return self._data[name].level,self._data[name].maxlevel
  else
    print("Warning: tree does not contain `"..tostring(name).."`")
    return debug_mode and 1 or 0,1
  end
end

return tree
