local action = {}

function action:new(init)

  init = init or {}

  local self = {}

  self.ai = init.ai

  self.update = action.update

  return self

end

function action:update(dt,ai)
  self.currentPocket = self.currentPocket or ai:getStartPocket()
  local user_id = ai:getUser().id
  for _,object in pairs(ai:getStorage().objects) do
    if object.user == user_id then
      if not libs.net.hasTarget(object) then
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

return action
