local explosions = {}

explosions.images = {}
for i = 1,6 do
  table.insert(
    explosions.images,
    love.graphics.newImage("assets/explosions/b"..i..".png")
  )
end

function explosions.new(init)
  init = init or {}
  local self = {}

  self.add = explosions.add
  self.update = explosions.update
  self.drawFow = explosions.drawFow
  self.draw = explosions.draw

  self.data = {}

  return self
end

function explosions:add(object,size)
  table.insert(self.data,{
    x = object.dx + math.random(-size,size),
    y = object.dy + math.random(-size,size),
    angle = math.random()*math.pi*2,
    dt = 0,
  })
end

function explosions:update(dt)
  for _,e in pairs(self.data) do
    e.dt = e.dt + dt*#explosions.images*4
  end
end

function explosions:draw()
  for ei,explosion in pairs(self.data) do
    local index = math.floor(explosion.dt)+1
    local img = explosions.images[index]
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
