local healthbar = {}

healthbar.images = {
  left = love.graphics.newImage("assets/hud/healthbar/left.png"),
  right = love.graphics.newImage("assets/hud/healthbar/right.png"),
  center = love.graphics.newImage("assets/hud/healthbar/center.png"),
  bar = love.graphics.newImage("assets/hud/healthbar/bar.png"),
}

function healthbar.new(init)
  init = init or {}
  local self = {}

  self._percent = init.percent or 0
  self._maxHealth = init.maxHealth or 1
  self._drawPercent = 0

  self.draw = healthbar.draw
  self.update = healthbar.update
  self.setPercent = healthbar.setPercent
  self.setMaxHealth = healthbar.setMaxHealth

  return self
end

function healthbar:draw(x,y,w)

  if self._drawPercent < 1 or love.keyboard.isDown("lalt") then

    love.graphics.setColor(255,255,255)
    love.graphics.draw(healthbar.images.left,
      x-healthbar.images.left:getWidth(),
      y-healthbar.images.left:getHeight()/2
    )
    love.graphics.draw(healthbar.images.center,
      x,
      y-healthbar.images.right:getHeight()/2,
      0,w,1
    )
    love.graphics.draw(healthbar.images.right,
      x+w,
      y-healthbar.images.right:getHeight()/2
    )
    love.graphics.setColor(libs.healthcolor(self._drawPercent))

    local maxBars = math.floor((w-1)/2+0.5)
    local bars = math.min(maxBars,math.max(1,self._maxHealth))
    local barSize = (w/bars)-1

    for i = 1,math.floor(bars*self._drawPercent+0.5) do
      local bx = x+(i-1)*(barSize+1)+1
      local by = y-healthbar.images.bar:getHeight()/2
      local bw = barSize
      love.graphics.draw(healthbar.images.bar,bx,by,0,bw,1)
    end

    love.graphics.setColor(255,255,255)

  end
end

function healthbar:update(dt)
  if debug_mode then
    self._drawPercent = (self._drawPercent + dt/8)%1
  else
    if math.abs(self._drawPercent - self._percent) < 0.05 then
      self._drawPercent = self._percent
    end
    if self._drawPercent < self._percent then
      self._drawPercent = self._drawPercent + dt
    elseif self._drawPercent > self._percent then
      self._drawPercent = self._drawPercent - dt
    end
  end
end

function healthbar:setPercent(val)
  self._percent = val
end

function healthbar:setMaxHealth(val)
  self._maxHealth = val
end

return healthbar
