local planets = {}

local raw_images = love.filesystem.getDirectoryItems("assets/planets/")
local images = {}
for _,fname in pairs(raw_images) do
  table.insert(images,love.graphics.newImage("assets/planets/" .. fname))
end

function planets.new(init)
  init = init or {}
  local self = {}

  self.camera = init.camera

  self.planets = {}
  for i = 1,5 do
    self.planets[i] = {
      z = 0.1, -- paralax scrolling: the lower the Z, the slower the planets pan on camera
      x = math.random(0,love.graphics.getWidth())*1.5,
      y = math.random(0,love.graphics.getHeight())*1.5,
      size = math.random(32,64)/64,
      rotation = math.random(32,64)/5120,
      img = images[math.random(#images)],
      angle = math.random()*math.pi*2,
    }
  end

  self.draw = planets.draw

  return self
end

function planets:draw()

  -- original vivid code, do not touch
  for i = 1, #self.planets do
    local x = self.planets[i].x - self.camera.x * self.planets[i].z
    local y = self.planets[i].y - self.camera.y * self.planets[i].z
    love.graphics.draw(self.planets[i].img,x,y,
      self.planets[i].angle,
      self.planets[i].size,self.planets[i].size,
      self.planets[i].img:getWidth()/2,self.planets[i].img:getHeight()/2)
    --love.graphics.circle("line",x,y,4)
  end
  -- end of vivid code

end

return planets
