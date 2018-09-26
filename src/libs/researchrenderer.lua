local researchrenderer = {}

researchrenderer.defaultPoints = 9000
researchrenderer._build_string = "build_"
researchrenderer._startObject = "command"

local data = {}

function researchrenderer.load(loadAssets)

  for _,current_object_type in pairs(researchrenderer.getResearchableObjects()) do
    local type = "_unlock_"..current_object_type.type
    local object = {
      type = type,
      icon = current_object_type.icons[1],
      valid = function(object_type,current_research)
        return current_object_type.type == object_type.type
      end,
      max_level = 1,
      default_level = current_object_type.default_level,
      cost = function(current)
        return 1
      end,
      value = function(current)
        return current
      end,
    }
    object.loc = {
      name="Unlock",
    }
    data[type] = object
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

    data[type] = object

  end

end

function researchrenderer.getResearchableObjects(list,startObject)
  list = list or {}
  startObject = startObject or researchrenderer._startObject
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
    if object.actions then
      for _,action in pairs(object.actions) do
        if starts_with(action,researchrenderer._build_string) then
          local newObject = action:sub(#researchrenderer._build_string+1)
          researchrenderer.getResearchableObjects(list,newObject)
        end
      end
    end
  end
  return list
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
  user.research = user.research or {}
  user.research[object_type] = user.research[object_type] or {}
  user.research[object_type][research_type] = value
end

function researchrenderer.buyLevel(user,object_type,research_type,value)
  local valid = true
  local target_level = researchrenderer.getLevel(user,object_type,research_type) + 1
  if target_level ~= value then
    valid = false
  end
  local research = researchrenderer.getType(research_type)
  local points = researchrenderer.getPoints(user)
  local cost = research.cost(target_level-1)
  if points < cost then
    valid = false
  end
  if target_level > research.max_level then
    valid = false
  end
  if valid then
    researchrenderer.setPoints(user,points-cost)
    researchrenderer.setLevel(user,object_type,research_type,value)
  end
end

function researchrenderer.getTypes()
  return data
end

function researchrenderer.getPoints(user)
  if user.research and user.research.points then
    return user.research.points
  else
    return researchrenderer.defaultPoints
  end
end

function researchrenderer.setPoints(user,points)
  user.research = user.research or {}
  user.research.points = points
end

function researchrenderer.getValidTypes(object_type,current_research)
  local valid = {}
  for _,research in pairs(data) do
    if research.valid(object_type,current_research) then
      table.insert(valid,research)
    end
  end
  table.sort(valid,function(a,b)
    return a.type < b.type
  end)
  return valid
end

return researchrenderer
