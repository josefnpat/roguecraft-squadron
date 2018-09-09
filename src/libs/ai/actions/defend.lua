local action = {}

local attack_timeout = 2

function action.new(init)
  init = init or {}
  local self = {}
  self.ai = init.ai
  self.updateFixed = action.updateFixed
  self.update = action.update
  self.attack_list = {}
  return self
end

local function makeAuxIndexedTable(t)
  local aux = {}
  local index = 1
  for _,value in pairs(t) do
    aux[index] = value
    index = index + 1
  end
  return aux
end

function action:updateFixed(ai)
  local actions,actions_count = {},0
  local user_id = ai:getUser().id
  local user_objects = {}
  local user_objects_shoot = {}
  local other_objects_with_targets = {}
  for _,object in pairs(ai:getStorage().objects) do
    if libs.net.userOwnsObject(ai:getUser(),object) then
      user_objects[object.index] = object
      local object_type = libs.objectrenderer.getType(object.type)
      if object_type.shoot then
        table.insert(user_objects_shoot,object)
      end
    end
    if object.user and not ai:getServer():objectIsAlly(ai:getUser(),object) then
      if object.target then
        table.insert(other_objects_with_targets,object)
      end
    end
  end
  for _,object in pairs(other_objects_with_targets) do
    if user_objects[object.target] then
      self.attack_list[object.target] = {
        object=object,
        dt=attack_timeout,
      }
    end
  end
  local indexedAttackList = makeAuxIndexedTable(self.attack_list)
  if #indexedAttackList > 0 then
    for _,object in pairs(user_objects_shoot) do
      if object.target == nil then
        local target = indexedAttackList[math.random(#indexedAttackList)].object
        table.insert(actions,function()
          libs.net.setObjectTarget(ai:getServer(),object,target.index)
        end)
        actions_count = actions_count + 1
      end
    end
  end

  for attackindex,attack in pairs(self.attack_list) do
    if attack.dt <= 0 or libs.net.objectShouldBeRemoved(attack.object) then
      for _,object in pairs(user_objects_shoot) do
        if object.target == attack.object.index then
          table.insert(actions,function()
            ai:getServer():stopUpdateObjectTarget(object)
          end)
          actions_count = actions_count + 1
        end
      end
      self.attack_list[attackindex] = nil
    end
  end

  return actions,actions_count

end

function action:update(dt,ai)
  for attackindex,attack in pairs(self.attack_list) do
    attack.dt = attack.dt - dt
  end
end

return action
