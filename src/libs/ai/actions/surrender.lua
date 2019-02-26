local action = {}

action._check_t = 5

function action.new(init)
  init = init or {}
  local self = {}
  self.updateFixed = action.updateFixed
  self.update = action.update
  self._check_dt = math.random()*action._check_t
  return self
end

function action:updateFixed(ai)
  return {},0
end

function action:update(dt,ai)
  if ai._surrender == false then
    return
  end
  self._check_dt = self._check_dt + dt
  if self._check_dt >= action._check_t then
    self._check_dt = 0
    local user = ai:getUser()
    local surrender = true
    local player_objects = {}
    for _,object in pairs(ai:getStorage().objects) do
      if object.user == user.id then
        table.insert(player_objects,object)
        object_type = libs.objectrenderer.getType(object.type)
        if object_type.speed then
          surrender = false
        end
      end
    end
    if surrender then
      for _,object in pairs(player_objects) do
        ai:getServer():addUpdate(object,{remove=true},"delete_objects")
        object.remove = true
      end
    end
  end

end

return action
