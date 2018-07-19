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

  self._action_t = 1
  self._action_dt = self._action_t*math.random()

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
    self._actions[action_index] = action.new()
  end

  self.update = ai.update
  self.setStartPocket = ai.setStartPocket
  self.getStartPocket = ai.getStartPocket

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

function ai:update(dt)
  for _,action in pairs(self._actions) do
    action:update(dt,self)
  end
  self._action_dt = self._action_dt + dt
  if self._action_dt > self._action_t then
    self._action_dt = self._action_dt - self._action_t
    -- todo: prioritize actions and only perform one
    for _,action in pairs(self._actions) do
      action:updateFixed(self)
    end
  end

end

function ai:setStartPocket(pocket)
  self._startPocket = pocket
end

function ai:getStartPocket()
  return self._startPocket
end

return ai
