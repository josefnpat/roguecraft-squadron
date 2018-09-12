local explosions = {}

local explosion_dir = "assets/explosions/"

explosions.assets = {}
for _,exptype in pairs(love.filesystem.getDirectoryItems(explosion_dir)) do
  local explosion = {}
  local frame_explosion_dir = explosion_dir .. exptype .. "/"
  for _,expframe in pairs(love.filesystem.getDirectoryItems(frame_explosion_dir)) do
    local frame = frame_explosion_dir .. expframe
    table.insert(explosion,love.graphics.newImage(frame))
  end
  table.insert(explosions.assets,explosion)
end

function explosions.new(init)
  init = init or {}
  local self = {}

  self.add = explosions.add
  self.update = explosions.update
  self.draw = explosions.draw

  self.data = {}

  return self
end

function explosions:add(object,size)
  table.insert(self.data,{
    type = math.random(#explosions.assets),
    x = object.dx + math.random(-size,size),
    y = object.dy + math.random(-size,size),
    angle = math.random()*math.pi*2,
    dt = 0,
  })
end

function explosions:update(dt)
  for _,e in pairs(self.data) do
    e.dt = e.dt + dt*#explosions.assets[e.type]
  end
end

function explosions:draw()
  for ei,explosion in pairs(self.data) do
    local index = math.floor(explosion.dt)+1
    local img = explosions.assets[explosion.type][index]
    if img then
      love.graphics.draw(img,
        explosion.x,explosion.y,
        explosion.angle,1,1,
        img:getWidth()/2,
        img:getHeight()/2)
    else
      table.remove(self.data,ei)
    end
  end
end

return explosions
