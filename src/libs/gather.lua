local gather = {}

gather.images = {}
for i = 1,4 do
  table.insert(
    gather.images,
    love.graphics.newImage("assets/effects/"..i..".png")
  )
end

function gather.new(init)
  init = init or {}
  local self = {}

  self.add = gather.add
  self.draw = gather.draw
  self.update = gather.update

  self.data = {}

  return self
end

function gather:add(x,y)
  table.insert(self.data,{
    x = x + math.random(-32,32),
    y = y + math.random(-32,32),
    angle = math.random()*math.pi*2,
    dt = 0,
  })
end

function gather:draw()
  love.graphics.setColor(255,255,255)
  for ei,effect in pairs(self.data) do
    local index = math.floor(effect.dt)+1
    local img = gather.images[index]
    if img then
      love.graphics.draw(img,
        effect.x,effect.y,
        effect.angle,1,1,
        img:getWidth()/2,
        img:getHeight()/2)
    else
      table.remove(self.data,ei)
    end
  end
end

function gather:update(dt)
  for _,e in pairs(self.data) do
    e.dt = e.dt + dt*#gather.images*4
  end
end

return gather
