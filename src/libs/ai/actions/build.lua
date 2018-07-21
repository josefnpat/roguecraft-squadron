local action = {}

function action:new(init)
  init = init or {}
  local self = {}
  self.ai = init.ai
  self.updateFixed = action.updateFixed
  self.update = action.update

  self.getPriority = action.getPriority
  self.getMaxCount = action.getMaxCount
  self.getTopPriority = action.getTopPriority
  self.actionBuildsPriority = action.actionBuildsPriority

  -- todo: add max unit count
  self.priority = {
    material_gather = 5,
    ore_gather = 3,
    construction_civilian = 3,
    construction_military = 1,
    ore_convert = 2,
    crew_gather = 3,
    material = 2,
    ore = 2,
    shoot = 0,
    repair = -math.huge,
    takeover = -math.huge,
  }

  self.max_count = {
    material_gather = 4,
    ore_gather = 4,
    construction_civilian = 2,
    construction_military = 4,
    ore_convert = 1,
    crew_gather = 5,
    material = 2,
    ore = 2,
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

function action:actionBuildsPriority(action,top_priority)
  local build_string = "build_"
  if not starts_with(action,build_string) then
    return false
  end
  local type_string = string.sub(action,#build_string+1)
  local object_type = libs.objectrenderer.getType(type_string)
  for _,priority in pairs(top_priority) do
    if object_type[priority] then
      return true
    end
  end
  return false
end

function action:updateFixed(ai)
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

  for _,parent in pairs(ai:getStorage().objects) do

    local parent_type = libs.objectrenderer.getType(parent.type)
    local can_build = {}
    if parent_type.actions then

      for action_index,action in pairs(parent_type.actions) do
        if self:actionBuildsPriority(action,top_priority) then
          table.insert(can_build,action)
        end
      end

      if #can_build > 0 then
        local action = can_build[math.random(#can_build)]
        libs.net.build(server,user,parent,action)
      end

    end
  end
end

function action:update(dt,ai)
end

return action
