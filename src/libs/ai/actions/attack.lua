local action = {}

function action.new(init)
  init = init or {}
  local self = {}
  self.updateFixed = action.updateFixed
  self.update = action.update

  -- initial attack time
  self._attack_t = math.random(-60,60)+4*60
  self._attack_dt = 0
  self._ready = false
  self._delayed_actions = {}

  return self
end

function action:updateFixed(ai)
  local actions,actions_count = {},0
  if #self._delayed_actions > 0 then
    for action_index,action in pairs(self._delayed_actions) do
      if action.delay <= 0 then
        table.insert(actions,action.actionf)
        actions_count = actions_count + 1
        table.remove(self._delayed_actions,action_index)
      end
    end
  end
  return actions,actions_count
end

function action:update(dt,ai)
  self._attack_dt = self._attack_dt + dt
  if self._attack_dt > self._attack_t then
    self._attack_dt = 0
    self._attack_t = math.random(-60,60)+4*60
    self._ready = true
  end
  if #self._delayed_actions > 0 then
    for _,action in pairs(self._delayed_actions) do
      action.delay = action.delay - dt
    end
  end
  if self._ready then
    local currentPocket = ai:getCurrentPocket()
    local randomPocket = ai:getRandomPocket(currentPocket)
    local distance = math.sqrt( (currentPocket.x-randomPocket.x)^2 + (currentPocket.y-randomPocket.y)^2 )
    local slowest_type = libs.objectrenderer.findSlowestShootType()
    local delay_base = distance/slowest_type.speed
    local user_id = ai:getUser().id
    for _,object in pairs(ai:getStorage().objects) do
      if object.user == user_id then
        local object_type = libs.objectrenderer.getType(object.type)
        if object_type.shoot and object_type.speed then
          local tx = randomPocket.x+math.random(-512,512)
          local ty = randomPocket.y+math.random(-512,512)
          table.insert(self._delayed_actions,{
            actionf=function()
              libs.net.moveToTarget(ai:getServer(),object,tx,ty,true)
            end,
            delay=delay_base-distance/object_type.speed,
          })
        end -- if attacking unit
      end -- if unit belongs to player
    end -- for each object
    self._ready = false
  end -- ready
end

return action
