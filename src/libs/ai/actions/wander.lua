local action = {}

function action:new(init)
  init = init or {}
  local self = {}
  self.ai = init.ai
  self.updateFixed = action.updateFixed
  self.update = action.update
  self.last_wander = {}
  return self
end

function action:updateFixed(ai)
  self.currentPocket = self.currentPocket or ai:getStartPocket()
  local user_id = ai:getUser().id
  for _,object in pairs(ai:getStorage().objects) do
    if object.user == user_id then
      if self.last_wander[object.index] == nil and not libs.net.hasTarget(object) then
        self.last_wander[object.index] = math.random()*5+5
        libs.net.moveToTarget(
          ai:getServer(),
          object,
          self.currentPocket.x+math.random(-512,512),
          self.currentPocket.y+math.random(-512,512),
          true)
      end
    end
  end
end

function action:update(dt,ai)
  local user_id = ai:getUser().id
  for _,object in pairs(ai:getStorage().objects) do
    if object.user == user_id then
      if self.last_wander[object.index] then
        self.last_wander[object.index] = self.last_wander[object.index] - dt
        if self.last_wander[object.index] <= 0 then
          self.last_wander[object.index] = nil
        end
      end
    end
  end
end

return action
