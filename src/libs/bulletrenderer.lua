local bulletrenderer = {}

local data = {}

function bulletrenderer.load(loadAssets)
  if loadAssets then
    bulletrenderer.images = {
      laser = love.graphics.newImage("assets/bullets/laser.png"),
      missile = love.graphics.newImage("assets/bullets/missile.png"),
    }
  end
end

function bulletrenderer.draw(bullet,objects,time)
  local object_type = libs.objectrenderer.getType(bullet.type)
  local image = bulletrenderer.images[object_type.shoot.image]
  local alpha = math.min(1,(time - bullet.tdt)/bullet.eta*4)
  love.graphics.setColor(255,255,255,alpha*255)
  love.graphics.draw(image,bullet.dx,bullet.dy,bullet.dangle or 0,
    1,1,image:getWidth()/2,image:getHeight()/2)
  if debug_mode then
    love.graphics.circle("line",bullet.dx,bullet.dy,16)
  end
  love.graphics.setColor(255,255,255)
end

function bulletrenderer.update(bullet,bullets,objects,dt,time)

  local target
  for _,object in pairs(objects) do
    if object.index == bullet.target then
      target = object
    end
  end

  if target == nil then
    target = {
      dx = bullet.tdx,
      dy = bullet.tdy,
      type = bullet.ttype,
    }
  end

  if target and target.dx and target.dy then

    local ctime = time - bullet.tdt
    local ratio = math.min(1,ctime/bullet.eta)

    bullet.tdx,bullet.tdy,bullet.ttype = target.dx,target.dy,target.type

    bullet.cx = (1-ratio)*bullet.x+ratio*target.dx
    bullet.cy = (1-ratio)*bullet.y+ratio*target.dy

    bullet.dx = (bullet.dx or bullet.cx) + (bullet.cx-bullet.dx)/2
    bullet.dy = (bullet.dy or bullet.cy) + (bullet.cy-bullet.dy)/2

    local distance = math.sqrt( (bullet.dx-target.dx)^2 + (bullet.dy-target.dy)^2 )
    local target_type = libs.objectrenderer.getType(target.type)

    if distance < target_type.size/2 then
      return false
    end

    bullet.angle = libs.net.getAngle(bullet.x,bullet.y,target.dx,target.dy)
    bullet.dangle = bullet.dangle or bullet.angle
    bullet.dangle = bullet.dangle + libs.net.shortestAngle(bullet.dangle,bullet.angle)*dt*4

    return true

  else

    return false

  end

end

return bulletrenderer
