local moveanim = {}

moveanim.image = love.graphics.newImage("assets/hud/target.png")

function moveanim.new(init)
  init = init or {}
  local self = {}

  self.add = moveanim.add
  self.draw = moveanim.draw
  self.update = moveanim.update

  return self
end

function moveanim:add(x,y,camera)
  self.target_show = {
    x=camera.x+x-love.graphics.getWidth()/2,
    y=camera.y+y-love.graphics.getHeight()/2,
    anim=0.25,
  }
end

function moveanim:draw()
  if self.target_show then
    local percent = self.target_show.anim/self.target_show.anim_max
    love.graphics.setColor(0,255,0)
    love.graphics.draw(moveanim.image,
      self.target_show.x,self.target_show.y,
      percent*math.pi/2,
      math.sqrt(percent),
      math.sqrt(percent),
      moveanim.image:getWidth()/2,
      moveanim.image:getHeight()/2)
    love.graphics.setColor(255,255,255)
  end
end

function moveanim:update(dt)
  if self.target_show then
    if not self.target_show.anim_max then
      self.target_show.anim_max = self.target_show.anim
    end
    self.target_show.anim = self.target_show.anim - dt
    if self.target_show.anim <= 0 then
      self.target_show = nil
    end
  end
end

return moveanim
