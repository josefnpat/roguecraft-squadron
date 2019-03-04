local researchrenderer = {}

researchrenderer.defaultPoints = 0
researchrenderer._build_string = "build_"

local data = {}

function researchrenderer.getUnlockName(type)
  return "_unlock_"..type
end

function researchrenderer.load(loadAssets,preset_value)

  --print("researchrenderer.load:"..preset_value)

  local preset = libs.mppresets.getPresets()[preset_value]

  for _,render in pairs(libs.levelshared.gen.getAllFirst()) do

    for _,current_object_type in pairs(researchrenderer.getResearchableObjects(nil,render)) do
      local type = researchrenderer.getUnlockName(current_object_type.type)
      local object = {
        type = type,
        valid = function(object_type,current_research)
          return current_object_type.type == object_type.type
        end,
        max_level = 1,
        default_level = current_object_type.default_level,
        cost = function(current)
          return current_object_type.unlock_cost or 0
        end,
        value = function(current)
          return current
        end,
      }
      if loadAssets then
        object.icon = current_object_type.icons[1]
      end
      object.loc = {
        name="Unlock",
      }
      data[type] = object
    end

  end

  for _,type in pairs(love.filesystem.getDirectoryItems("assets/mp_research")) do
    local dir = "assets/mp_research/"..type

    local object = require(dir)
    object.type = type -- screw you, inheritance!
    if loadAssets then

      local po_file = dir.."/en.po"
      if love.filesystem.exists(po_file) then
        local po_raw = love.filesystem.read(po_file)

        object.loc = {}
        for _,entry in pairs(libs.gettext.decode(po_raw)) do
          object.loc[entry.id] = entry.str
        end
        for _,post in pairs({"name"}) do
          local id = "research."..type.."."..post
          object.loc[post] = object.loc[id]
          if object.loc[id] == nil then
            print("warning: missing gettext id: "..id)
          end
        end
      else
        print("warning: missing file `"..po_file.."`")
      end

      object.icon = love.graphics.newImage(dir.."/icon.png")

    end

    if not object.disabled then
      data[type] = object
    end

  end

end

function researchrenderer.getResearchableObjects(list,startObject)
  list = list or {}
  assert(startObject)
  local object = libs.objectrenderer.getType(startObject)
  local in_list = false
  for _,listObject in pairs(list) do
    if object == listObject then
      in_list = true
      break
    end
  end
  if not in_list then
    table.insert(list,object)
    for _,newObject in pairs(researchrenderer.getBuildObjects(object)) do
      researchrenderer.getResearchableObjects(list,newObject)
    end
  end
  return list
end

function researchrenderer.getBuildObjects(object)
  local objects = {}
  if object.actions then
    for _,action in pairs(object.actions) do
      if starts_with(action,researchrenderer._build_string) then
        local newObject = action:sub(#researchrenderer._build_string+1)
        table.insert(objects,newObject)
      end
    end
  end
  return objects
end

function researchrenderer.isUnlockable(user,objects,testObject)
  for _,object in pairs(objects) do
    for _,buildObject in pairs(researchrenderer.getBuildObjects(object)) do
      if testObject.type == buildObject then
        local currentLevel = researchrenderer.getLevel(
          user,
          object.type,
          researchrenderer.getUnlockName(object.type)
        )
        if currentLevel > 0  then
          return true
        end
      end
    end
  end
  return false
end

function researchrenderer.isUnlocked(user,object)
  return researchrenderer.getLevel(user,object.type,researchrenderer.getUnlockName(object.type)) > 0
end

function researchrenderer.getUnlockCost(user,object_type)
  local research_type = researchrenderer.getUnlockName(object_type.type)
  local research = researchrenderer.getType(research_type)
  local target_level = researchrenderer.getLevel(user,object_type.type,research_type) + 1
  return research.cost(target_level) or 0
end

function researchrenderer.canAffordUnlock(user,object_type,points)
  local cost = researchrenderer.getUnlockCost(user,object_type)
  return points >= cost
end

function researchrenderer.getUnlockedObjects(user,preset_value)

  local preset = libs.mppresets.getPresets()[preset_value]
  local gen_render = preset.gen()
  local objects = researchrenderer.getResearchableObjects(nil,gen_render.first)
  local activeObjects = {}
  for _,object in pairs(objects) do
    if researchrenderer.isUnlocked(user,object)  then
      table.insert(activeObjects,object)
    else
      if researchrenderer.isUnlockable(user,objects,object) then
        table.insert(activeObjects,object)
      end
    end
  end
  return activeObjects
end

function researchrenderer.setUnlocked(user,object_type,value)
  assert(type(user)=="table")
  assert(type(object_type)=="string")
  libs.researchrenderer.setLevel(
    user,
    object_type,
    researchrenderer.getUnlockName(object_type),
    value == false and 0 or 1)
end

function researchrenderer.getType(type)
  if data[type] == nil then
    print("Type `"..tostring(type).."` does not exist.")
  end
  return data[type]
end

function researchrenderer.getLevel(user,object_type,research_type)
  assert(type(user)=="table")
  assert(type(object_type)=="string")
  assert(type(research_type)=="string")
  local research = researchrenderer.getType(research_type)
  if user.research and user.research[object_type] and user.research[object_type][research_type] then
    return user.research[object_type][research_type]
  end
  if research.default_level then
    return research.default_level
  end
  return 0
end

function researchrenderer.setLevel(user,object_type,research_type,value)
  assert(type(user)=="table")
  assert(type(object_type)=="string")
  assert(type(research_type)=="string")
  assert(type(value)=="number")
  user.research = user.research or {}
  user.research[object_type] = user.research[object_type] or {}
  user.research[object_type][research_type] = value
end

function researchrenderer.buyLevel(user,object_type,research_type,value,points)
  assert(user)
  assert(object_type)
  assert(research_type)
  assert(value)
  assert(points)
  local valid = true
  local target_level = researchrenderer.getLevel(user,object_type,research_type) + 1
  if target_level ~= value then
    valid = false
  end
  local research = researchrenderer.getType(research_type)
  local cost = research.cost(target_level-1)
  if points < cost then
    valid = false
  end
  if target_level > research.max_level then
    valid = false
  end
  if valid then
    researchrenderer.setLevel(user,object_type,research_type,value)
  end
  return valid,cost
end

function researchrenderer.getTypes()
  return data
end

function researchrenderer.getValidTypes(object_type,user)
  local valid = {}
  for _,research in pairs(data) do
    if research.valid(object_type,user) then
      table.insert(valid,research)
    end
  end
  table.sort(valid,function(a,b)
    return a.type < b.type
  end)
  return valid
end

return researchrenderer
