local gather = {}

gather.images = {}
for i = 0,9 do
  table.insert(
    gather.images,
    love.graphics.newImage("assets/gather/tile00"..i..".png")
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

function gather:add(x,y,user_id)
  table.insert(self.data,{
    x = x + math.random(-16,16),
    y = y + math.random(-16,16),
    angle = math.random()*math.pi*2,
    dt = 0,
    user = user_id,
  })
end

function gather:draw()
  love.graphics.setColor(255,255,255)
  for ei,effect in pairs(self.data) do
    local index = math.floor(effect.dt)+1
    local img = gather.images[index]
    if img then
      local user = libs.net.getUser(effect.user)
      love.graphics.setColor(user.color)
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
