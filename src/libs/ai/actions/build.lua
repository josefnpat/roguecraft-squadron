local action = {}

local _build_string = "build_"

function action:new(init)
  init = init or {}
  local self = {}
  self.ai = init.ai
  self.updateFixed = action.updateFixed
  self.update = action.update

  self.getPriority = action.getPriority
  self.getMaxCount = action.getMaxCount
  self.getTopPriority = action.getTopPriority
  self.getTypeFromAction = action.getTypeFromAction
  self.actionBuildsPriority = action.actionBuildsPriority
  self.canAffordMaxCost = action.canAffordMaxCost

  -- todo: add max unit count
  self.priority = {
    construction_command = 5,
    material_gather = 4,
    ore_gather = 3,
    construction_civilian = 3,
    construction_military = 1,
    ore_convert = 2,
    crew_gather = 3,
    military_small = 5,
    military_large = 0,
    cargo = 2,
    repair = -math.huge,
    takeover = -math.huge,
  }

  self.max_count = {
    material_gather = 6,
    ore_gather = 6,
    construction_command = 1,
    construction_civilian = 4,
    construction_military = 8,
    ore_convert = 4,
    crew_gather = 5,
    cargo = 8,
    military_small = 16,
    military_large = math.huge,
  }

  self.owned_pockets = 1

  return self
end

function action:getPriority(objects)
  local priority_count = {}
  local current_priority = {}
  for priority,priority_count in pairs(self.priority) do
    current_priority[priority] = priority_count
  end
  for _,object in pairs(objects) do
    local object_type = libs.objectrenderer.getType(object.type)
    for priority,_ in pairs(self.priority) do
      if object_type[priority] then
        current_priority[priority] = current_priority[priority] - 1
        priority_count[priority] = (priority_count[priority] or 0)+1
      end
    end
  end

  for priority,priority_count in pairs(priority_count) do
    if self.max_count[priority] and priority_count >= self.max_count[priority]*self.owned_pockets then
      current_priority[priority] = nil
    end
  end

  -- print(">>>current_priority:")
  -- for i,v in pairs(current_priority) do print(i,v) end

  return current_priority
end

function action:getMaxCount(current_priority)
  local max = -math.huge
  for priority,count in pairs(current_priority) do
    max = math.max(max,count)
  end
  return max
end

function action:getTopPriority(objects)
  local current_priority = self:getPriority(objects)
  local top_priority = {}
  local max_priority = action:getMaxCount(current_priority)
  -- todo: change priority table when civilian part ready?
  -- print(">>>max_priority:",max_priority)
  for priority,priority_count in pairs(current_priority) do
    -- print(priority,priority_count)
    if priority_count == max_priority then
      table.insert(top_priority,priority)
    end
  end
  return top_priority
end

function action:getTypeFromAction(action)
  local type_string = string.sub(action,#_build_string+1)
  local object_type = libs.objectrenderer.getType(type_string)
  return object_type
end

function action:actionBuildsPriority(action,top_priority)
  if not starts_with(action,_build_string) then
    return false
  end
  local object_type = self:getTypeFromAction(action)
  for _,priority in pairs(top_priority) do
    if object_type[priority] then
      return true
    end
  end
  return false
end

function action:canAffordMaxCost(user,max_cost)
  for _,restype in pairs(libs.net.resourceTypes) do
    if user.resources[restype] < max_cost[restype] then
      return false
    end
  end
  return true
end

function action:updateFixed(ai)

  local actions,actions_count = {},0

  -- print('>>>start build ai:')
  local user = ai:getUser()
  local server = ai:getServer()

  local current_objects = {}

  for _,object in pairs(ai:getStorage().objects) do
    if object.user == user.id then
      table.insert(current_objects,object)
    end
  end

  local top_priority = self:getTopPriority(current_objects)
  -- print(">>>top_priority:")
  -- for i,v in pairs(top_priority) do print(i,v) end

  if true then --self:canAffordMaxCost(user,max_cost) then
    for _,parent in pairs(ai:getStorage().objects) do

      local parent_type = libs.objectrenderer.getType(parent.type)
      local can_build = {}
      if parent_type.actions then

        for action_index,action in pairs(parent_type.actions) do
          if self:actionBuildsPriority(action,top_priority) then
            table.insert(can_build,action)
          end
        end

        local max_cost = {}
        for _,action in pairs(can_build) do
          local object_type = self:getTypeFromAction(action)
          for _,restype in pairs(libs.net.resourceTypes) do
            max_cost[restype] = math.max(
              max_cost[restype] or 0,
              object_type.cost[restype] or 0)
          end
        end

        if #can_build > 0 and self:canAffordMaxCost(user,max_cost) then
          local action = can_build[math.random(#can_build)]
          table.insert(actions,function()
            libs.net.build(server,user,parent,action)
          end)
          actions_count = actions_count + 1
        end

      end

    end
  end

  return actions,actions_count

end

function action:update(dt,ai)
end

return action
