local ai = {}

ai.actions = {}
local ai_dir = "libs/ai/actions/"
for i,v in pairs(love.filesystem.getDirectoryItems(ai_dir)) do
  local name = file.name(v)
  ai.actions[name] = require(ai_dir .. name)
end

function ai.new(init)
  init = init or {}

  local self = {}

  self.getUser = ai.getUser
  self._user = init.user
  assert(self._user)

  self.getPockets = ai.getPockets
  self._pockets = init.pockets
  assert(self._pockets)

  self.getStorage = ai.getStorage
  self._storage = init.storage
  assert(self._storage)

  self.getServer = ai.getServer
  self._server = init.server
  assert(self._server)

  self.getActions = ai.getActions
  self._actions = {}
  for action_index,action in pairs(ai.actions) do
    self._actions[action_index] = action.new{preset=self._storage.config.preset}
  end

  self.setDiff = ai.setDiff
  self.updateDiff = ai.updateDiff
  self.update = ai.update
  self.setCurrentPocket = ai.setCurrentPocket
  self.getCurrentPocket = ai.getCurrentPocket
  self.setPockets = ai.setPockets
  self.getPockets = ai.getPockets
  self.getRandomPocket = ai.getRandomPocket
  self.setSurrender = ai.setSurrender
  self.getSurrender = ai.getSurrender
  self.setUseRandomPocket = ai.setUseRandomPocket
  self.getUseRandomPocket = ai.getUseRandomPocket

  self._diff = self._user.config.diff or 1
  self:updateDiff()
  self._current_aps = 0
  self._queue = {}
  self._surrender = true
  self._useRandomPockets = false

  return self
end

function ai:getUser()
  return self._user
end

function ai:getPockets()
  return self._pockets
end

function ai:getStorage()
  return self._storage
end

function ai:getServer()
  return self._server
end

function ai:getActions()
  return self._actions
end

function ai:setDiff(diff)
  self._diff = diff
  self:updateDiff()
end

function ai:updateDiff()
  local diff = libs.net.aiDifficulty[self._diff]
  self._aps = diff.apm()/60 -- actions per second
end

function ai:update(dt)

  for _,action in pairs(self._actions) do
    action:update(dt,self)
  end

  self._current_aps = math.max(0,self._current_aps - self._aps * dt)

  if self._current_aps <= 0 then

    if #self._queue == 0 then
      local actions_count = 0
      for action_index,sub_action in pairs(self._actions) do
        local sub_actions,sub_actions_count = sub_action:updateFixed(self)
        for _,sub_action in pairs(sub_actions) do
          table.insert(self._queue,sub_action)
        end
        actions_count = actions_count + sub_actions_count
      end
    end

    local new_queue = {}
    for action_index,action in pairs(self._queue) do
      if self._current_aps <= 0 then
        action()
        self._current_aps = self._current_aps + 1
      else
        table.insert(new_queue,action)
      end
    end
    self._queue = new_queue

  end

end

function ai:setCurrentPocket(pocket)
  self._currentPocket = pocket
end

function ai:getCurrentPocket()
  return self._currentPocket
end

function ai:setPockets(pockets)
  self._pockets = pockets
end

function ai:getPockets()
  return self._pockets
end

function ai:getRandomPocket(exclude)
  local pocket
  while true do
    pocket = self._pockets[math.random(#self._pockets)]
    if pocket ~= exclude then
      return pocket
    end
  end
end

function ai:setSurrender(val)
  self._surrender = val
end

function ai:getSurrender()
  return self._surrender
end

function ai:setUseRandomPocket(val)
  self._useRandomPockets = val
end

function ai:getUseRandomPocket()
  return self._useRandomPockets
end

return ai
