local objectrenderer = {}

objectrenderer.pizza = false
objectrenderer.circle_padding = 4

local data = {}

function objectrenderer.load(loadAssets)

  data = {}

  if loadAssets then
    objectrenderer.tooltip_icons = {}
    local dir = "assets/hud/tooltip_icons/"
    for _,tooltip_file in pairs(love.filesystem.getDirectoryItems(dir)) do
      objectrenderer.tooltip_icons[file.name(tooltip_file)] = love.graphics.newImage(dir..tooltip_file)
    end
  end

  for _,type in pairs(love.filesystem.getDirectoryItems("assets/mp_objects")) do
    local dir = "assets/mp_objects/"..type
    local object_dir = dir.."/object"
    local renders_dir = dir.."/renders"
    local subrenders_dir = dir.."/subrenders"
    local icons_dir = dir.."/icons"

    local object = require(object_dir)()
    if loadAssets then

      objectrenderer.chevron = love.graphics.newImage("assets/hud/chevron.png")

      local po_file = dir.."/en.po"
      if love.filesystem.exists(po_file) then
        local po_raw = love.filesystem.read(po_file)

        object.loc = {}
        for _,entry in pairs(libs.gettext.decode(po_raw)) do
          object.loc[entry.id] = entry.str
        end
        for _,post in pairs({"name","info","build"}) do
          local id = "mission.object."..type.."."..post
          object.loc[post] = object.loc[id]
          if object.loc[id] == nil then
            print("warning: missing gettext id: "..id)
          end
        end
      else
        print("warning: missing file `"..po_file.."`")
      end
    end

    local renders = love.filesystem.getDirectoryItems(renders_dir)
    object.renders_count = #renders
    if loadAssets then
      object.renders = {}
      object.icons = {}
      for _,render in pairs(renders) do
        local renderdata = {}

        function newImagePad(image_uri,pad)
          local orig = love.image.newImageData( image_uri )
          local new = love.image.newImageData( orig:getWidth()+pad*2, orig:getHeight()+pad*2 )
          new:paste(orig,pad,pad,0,0,orig:getWidth(),orig:getHeight())
          return love.graphics.newImage(new)
        end

        renderdata.main = newImagePad(renders_dir.."/"..render,32)
        if love.filesystem.exists(subrenders_dir.."/"..render) then
          renderdata.sub = newImagePad(subrenders_dir.."/"..render,32)
        end
        table.insert(object.renders,renderdata)
        table.insert(object.icons,love.graphics.newImage(icons_dir.."/"..render))
      end
    end
    data[type] = object
  end
end

function objectrenderer.init(object)
  object.dangle = object.angle
  object.subdangle = object.angle
  if object.health then
    local object_type = libs.objectrenderer.getType(object.type)
    object.healthbar = libs.healthbar.new{
      maxHealth = object_type.health.max
    }
  end
end

function objectrenderer.tooltip(object,object_type,x,y)
  local name = object_type.loc.name or ""
  if object_type.names then
    name = object_type.names[object.name]
  end
  tooltipf(name.." — "..(object_type.loc.info or ""),
    x,y,320,"right")
end

function objectrenderer.tooltipBuild(object_type,x,y,points,resources)
  local data = {}

  table.insert(data,{text="Build "..object_type.loc.name})

  --table.insert(data,{text=object_type.loc.info})

  if object_type.points and object_type.points > 0 then
    table.insert(data,{
      image=objectrenderer.tooltip_icons.points,
      text=object_type.points .. " command point(s)",
      afford=object_type.points + points:getPointsValue() <= points:getMax(),
    })
  end

  if object_type.cost then
    if object_type.cost.material then
      table.insert(data,{
        image=objectrenderer.tooltip_icons.material,
        text=object_type.cost.material .. " material",
        afford=resources:canAffordResType(object_type,"material"),
      })
    end
    if object_type.cost.crew then
      table.insert(data,{
        image=objectrenderer.tooltip_icons.crew,
        text=object_type.cost.crew .. " crew",
        afford=resources:canAffordResType(object_type,"crew"),
      })
    end
    if object_type.cost.ore then
      table.insert(data,{
        image=objectrenderer.tooltip_icons.ore,
        text=object_type.cost.ore .. " ore",
        afford=resources:canAffordResType(object_type,"ore"),
      })
    end
  end

  if object_type.build_time then
    table.insert(data,{
      image=objectrenderer.tooltip_icons.build_time,
      text=object_type.build_time .. " second(s)",
    })
  end

  table.insert(data,{text="Stats:"})

  if object_type.health then
    table.insert(data,{
      image=objectrenderer.tooltip_icons.health_max,
      text=object_type.health.max .. " health",
    })
  end

  if object_type.shoot then
    table.insert(data,{
      image=objectrenderer.tooltip_icons.shoot_dps,
      text=math.floor(object_type.shoot.damage/object_type.shoot.reload*10)/10 .. " dps",
    })
    table.insert(data,{
      image=objectrenderer.tooltip_icons.shoot_range,
      text=object_type.shoot.range .. " range",
    })
  end

  if object_type.explode then
    table.insert(data,{
      image=objectrenderer.tooltip_icons.explode_damage,
      text=object_type.explode.damage .. " damage",
    })
    table.insert(data,{
      image=objectrenderer.tooltip_icons.explode_range,
      text=object_type.explode.range .. "/" .. object_type.explode.damage_range .. " range",
    })
  end

  if object_type.speed then
    table.insert(data,{
      image=objectrenderer.tooltip_icons.speed,
      text=object_type.speed .. " kph",
    })
  end

  table.insert(data,{
    image=objectrenderer.tooltip_icons.fow,
    text=math.floor((object_type.fow or 1)*512) .. " vision",
  })

  local padding = 8
  local width = 0
  local font = love.graphics.getFont()
  for _,v in pairs(data) do
    if v.image then
      width = math.max(width,font:getWidth(v.text)+v.image:getWidth()+padding)
    else
      width = math.max(width,font:getWidth(v.text))
    end
  end
  tooltipbg(x,y,width+padding*2,#data*font:getHeight()+padding*2)

  for i,v in pairs(data) do
    local yoff = y+(i-1)*font:getHeight()+padding
    love.graphics.setColor(255,255,255)
    if v.image then
      local yimageoff = math.floor((font:getHeight()-v.image:getHeight())/2+0.5)
      dropshadow(v.text,x+padding*2+v.image:getWidth(),yoff)
      if v.afford == true then
        love.graphics.setColor(0,255,0)
      elseif v.afford == false then
        love.graphics.setColor(255,0,0)
      else
        love.graphics.setColor(0,255,255)
      end
      love.graphics.draw(objectrenderer.tooltip_icons.bg,x+padding,yoff+yimageoff)
      love.graphics.draw(v.image,x+padding,yoff+yimageoff)
    else
      dropshadow(v.text,x+padding,yoff)
    end

  end

end

function objectrenderer.getType(type)
  if data[type] == nil then
    print("Type `"..tostring(type).."` does not exist.")
  end
  return data[type]
end

function objectrenderer.getTypes()
  return data
end

function objectrenderer.randomRenderIndex(type)
  return math.random(type.renders_count)
end

function objectrenderer.randomNameIndex(type)
  if type.names then
    return math.random(#type.names)
  end
end

function objectrenderer.findSlowestShootType()
  local slowest_type,speed = nil,math.huge
  for type,object_type in pairs(data) do
    if object_type.speed and object_type.shoot then
      if object_type.speed < speed then
        slowest_type = object_type
        speed = object_type.speed
      end
    end
  end
  return slowest_type
end

function objectrenderer.drawChevron(object,selection)

  local isSelected = selection:isSelected(object)

  if isSelected then
    love.graphics.setColor(libs.net.getUser(object.user).selected_color)
  else
    love.graphics.setColor(libs.net.getUser(object.user).color)
  end

  love.graphics.draw(objectrenderer.chevron,
    object.dx,object.dy,0,1,1,
    objectrenderer.chevron:getWidth()/2,objectrenderer.chevron:getHeight()/2)

end

function objectrenderer.drawShip(object)

  local object_type = objectrenderer.getType(object.type)

  if object_type.renders[object.render].sub then
    love.graphics.draw(
      object_type.renders[object.render].sub,
      object.dx,
      object.dy,
      object.subdangle,
      1,1,
      object_type.renders[object.render].sub:getWidth()/2,
      object_type.renders[object.render].sub:getHeight()/2)
  end

  local render = object_type.renders[object.render].main
  if objectrenderer.pizza then
    objectrenderer.pizza_img = objectrenderer.pizza_img or love.graphics.newImage("assets/pizza.png")
    render = objectrenderer.pizza_img
  end

  love.graphics.draw(
    render,
    object.dx,
    object.dy,
    object.dangle,
    1,1,
    render:getWidth()/2,
    render:getHeight()/2)

end

function objectrenderer.draw(object,objects,selection,time,user_id,players)

  local object_type = objectrenderer.getType(object.type)

  if settings:read("object_shaders") then
    if not objectrenderer.outline_shader then
      objectrenderer.outline_shader = love.graphics.newShader( "assets/shaders/outline.glsl")
    end
  end

  if object.anim then
    love.graphics.setColor(255,255,255,127)
    if object.user == nil then
      love.graphics.setColor(255,255,0)
    elseif object.user == user_id then
      love.graphics.setColor(0,255,255)
    elseif libs.net.isOnSameTeam(players,user_id,object.user) then
      love.graphics.setColor(0,255,0)
    else
      love.graphics.setColor(255,0,0)
    end
    love.graphics.circle("line",
      object.dx,
      object.dy,
      object_type.size+objectrenderer.circle_padding+math.sin(object.anim*math.pi)*4
    )
  end

  local isSelected = selection:isSelected(object)

  if isSelected then
    love.graphics.setColor(libs.net.getUser(object.user).selected_color)
  else
    love.graphics.setColor(libs.net.getUser(object.user).color)
  end

  if isSelected then
    if not settings:read("object_shaders") then
      love.graphics.circle("line",
        object.dx,
        object.dy,
        object_type.size+objectrenderer.circle_padding
      )
    end
    if #selection:getSelected() == 1 then
      if object_type.shoot then
        love.graphics.setColor(0,255,255)
        libs.ring.draw(object.dx,object.dy,object_type.shoot.range)
      end
      if object_type.explode then
        love.graphics.setColor(255,0,0)
        libs.ring.draw(object.dx,object.dy,object_type.explode.range)
        love.graphics.setColor(0,255,255)
        libs.ring.draw(object.dx,object.dy,object_type.explode.damage_range)
      end
    end
  end

  if object.health then
    if object.health then
      object.healthbar:draw(
        object.dx-object_type.size,
        object.dy+object_type.size,
        object_type.size*2
      )
    end
  end

  if object.build_t and object.build_dt then
    local user = libs.net.getUser(object.user)
    love.graphics.setColor(user.color[1],user.color[2],user.color[3],isSelected and 127 or 63)
    local percent = 1-object.build_dt/object.build_t
    libs.pcb(object.dx,object.dy,object_type.size*1.5,0.75,percent,0)
  end

  love.graphics.setColor(255,255,255)

  if isSelected and settings:read("object_shaders") then
    local anim_size = 1
    if object.anim then
      anim_size = anim_size + math.sin(object.anim*math.pi)*1
    end
    anim_size = anim_size/object_type.size
    objectrenderer.outline_shader:send("outline",{anim_size,anim_size} )
    local user = libs.net.getUser(object.user)
    local color = {user.selected_color[1]/255,user.selected_color[2]/255,user.selected_color[3]/255}
    objectrenderer.outline_shader:send("color",color)
    love.graphics.setShader(objectrenderer.outline_shader)
    objectrenderer.drawShip(object)
    love.graphics.setShader()
  end
  objectrenderer.drawShip(object)

  love.graphics.setColor(255,255,255)
  if debug_mode then

    if object.tx and object.ty then
      love.graphics.line(object.x,object.y,object.tx,object.ty)
      local cx,cy = libs.net.getCurrentLocation(object,time)
      love.graphics.circle('line',cx,cy,8)
    end

    if object_type.shoot then
      love.graphics.circle('line',object.dx,object.dy,object_type.shoot.range)
    end

    local str = ""
    str = str .. "index: " .. object.index .. "\n"
    str = str .. "target: " .. tostring(object.target) .. "\n"
    str = str .. "d: ["..math.floor(object.dx)..","..math.floor(object.dy).."]\n"
    love.graphics.printf(str,object.dx-64,object.dy,128,"center")
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

  end
  love.graphics.setColor(255,255,255)

end

function objectrenderer.update(object,objects,dt,time,user)

  local cx,cy = libs.net.getCurrentLocation(object,time)
  object.dx = (object.dx or cx) + (cx-object.dx)/2
  object.dy = (object.dy or cy) + (cy-object.dy)/2

  local object_type = objectrenderer.getType(object.type)

  if object.health then
    object.healthbar:update(dt)
    object.healthbar:setPercent(object.health/object_type.health.max)
  end

  if object_type.rotate then
    object.angle = object.angle + object_type.rotate*dt
  end

  if object.tx and object.ty then
    object.angle = libs.net.getAngle(object.x,object.y,object.tx,object.ty)
  elseif object.target then
    local target = libs.net.findObject(objects,object.target)
    if target then
      object.angle = libs.net.getAngle(object.dx,object.dy,target.dx,target.dy)
    end
  end

  object.dangle = object.dangle + libs.net.shortestAngle(object.dangle,object.angle)*dt*(object_type.dangle_speed or 4)
  object.subdangle = object.subdangle + libs.net.shortestAngle(object.subdangle,object.angle)*dt*(object_type.subdangle_speed or 4)

  if object.anim then
    object.anim = object.anim - dt*4
    if object.anim < 0 then
      object.anim = nil
    end
  end

  if object.build_t then
    object.build_dt = (object.build_dt or object.build_t) - dt
    if object.build_dt <= 0 then
      if user and user.id == object.user then
        libs.sfx.loopGroup("action.build.end")
      end
      object.build_t = nil
      object.build_dt = nil
    end
  end

end

return objectrenderer
