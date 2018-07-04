local ring = {}

ring.images = {
  small = love.graphics.newImage("assets/hud/ring/small.png"),
  large = love.graphics.newImage("assets/hud/ring/large.png"),
}

function ring.draw(x,y,radius)
  for i = 1,16 do
    local rot = i*math.pi/2/4+love.timer.getTime()/4
    local dx = radius*math.cos(rot)+x
    local dy = radius*math.sin(rot)+y
    local image = math.floor(i/4) == i/4 and ring.images.large or ring.images.small
    love.graphics.draw(image,dx,dy,rot,1,1,
      image:getWidth()/2,
      image:getHeight()/2)
  end
end

return ring
