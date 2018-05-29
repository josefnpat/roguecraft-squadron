local objectrenderer = {}

local data = {}

function objectrenderer.load(loadAssets)
  for _,type in pairs(love.filesystem.getDirectoryItems("assets/mp_objects")) do
    local object_dir = "assets/mp_objects/"..type.."/object"
    local renders_dir ="assets/mp_objects/"..type.."/renders"
    local icons_dir = "assets/mp_objects/"..type.."/icons"
    local renders = love.filesystem.getDirectoryItems(renders_dir)
    local object = require(object_dir)()
    object.renders_count = #renders
    if loadAssets then
      object.renders = {}
      object.icons = {}
      for _,render in pairs(renders) do
        table.insert(object.renders,love.graphics.newImage(renders_dir.."/"..render))
        table.insert(object.renders,love.graphics.newImage(icons_dir.."/"..render))
      end
    end
    data[type] = object
  end
end

function objectrenderer.getType(type)
  if data[type] == nil then
    print("Type `"..tostring(type).."` does not exist.")
  end
  return data[type]
end

function objectrenderer.randomRenderIndex(type)
  return math.random(type.renders_count)
end

function objectrenderer.draw(object,objects,isSelected,time)

  local type = objectrenderer.getType(object.type)

  if isSelected then
    love.graphics.setColor(libs.net.getUser(object.user).selected_color)
  else
    love.graphics.setColor(libs.net.getUser(object.user).color)
  end

  love.graphics.circle("line",
    object.dx,
    object.dy,
    object.size
  )

  love.graphics.setColor(255,255,255)
  love.graphics.draw(type.renders[object.render],object.dx,object.dy,object.dangle,1,1,type.size,type.size)

  love.graphics.setColor(255,255,255)
  if debug_mode then
    if object.tx and object.ty then
      love.graphics.line(object.x,object.y,object.tx,object.ty)
      local cx,cy = libs.net.getCurrentLocation(object,time)
      love.graphics.circle('line',cx,cy,16)
    end
    local str = ""
    str = str .. "index: " .. object.index .. "\n"
    str = str .. "target: " .. tostring(object.target) .. "\n"
    str = str .. "user: " .. libs.net.getUser(object.user).name .. "["..object.user.."]\n"
    str = str .. "angle: " .. object.angle .. "\n"
    str = str .. "dangle: " .. object.dangle .. "\n"
    love.graphics.printf(str,object.dx-64,object.dy,128,"center")
  end

  love.graphics.setColor(0,255,0,63)
  for _,target in pairs(objects) do
    if target.index == object.target then
      love.graphics.line(
        object.dx,
        object.dy,
        target.dx,
        target.dy)
      break
    end
  end
  love.graphics.setColor(255,255,255)

end

function objectrenderer.shortestAngle(c,t)
  return (t-c+math.pi)%(math.pi*2)-math.pi
end

function objectrenderer.update(object,objects,dt,time)
  local cx,cy = libs.net.getCurrentLocation(object,time)
  object.dx = (object.dx or cx) + (cx-object.dx)/2
  object.dy = (object.dy or cy) + (cy-object.dy)/2

  if object.tx and object.ty then
    object.angle = libs.net.getAngle(object.x,object.y,object.tx,object.ty)
  end

  object.dangle = object.dangle + objectrenderer.shortestAngle(object.dangle,object.angle)*dt*4

end

return objectrenderer
