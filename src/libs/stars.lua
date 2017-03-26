local stars = {}

stars.planet = love.graphics.newImage("assets/planets/BubblegumPlanet.png")

function stars:load()

  self.img = {
    space = love.graphics.newImage("assets/space.png"),
    stars0 = love.graphics.newImage("assets/stars0.png"),
    stars1 = love.graphics.newImage("assets/stars1.png"),
  }

  self.img.stars0:setWrap("repeat","repeat")
  self.stars0_quad = love.graphics.newQuad(0,0,
    love.graphics.getWidth()+self.img.stars0:getWidth(),
    love.graphics.getHeight()+self.img.stars0:getHeight(),
    self.img.stars0:getWidth(), self.img.stars0:getHeight())

  self.img.stars1:setWrap("repeat","repeat")
  self.stars1_quad = love.graphics.newQuad(0, 0,
    love.graphics.getWidth()+self.img.stars1:getWidth(),
    love.graphics.getHeight()+self.img.stars1:getHeight(),
    self.img.stars1:getWidth(), self.img.stars1:getHeight())

  self.background_scroll_speed = 4

end

function stars:reload()
  self:load()
end

stars:load()

function stars:draw(x,y)
  x = x and -x or love.timer.getTime()*self.background_scroll_speed
  y = y and -y or love.timer.getTime()*self.background_scroll_speed
  love.graphics.setColor(255,255,255)
  love.graphics.draw(self.img.space,0,0,0,
    love.graphics.getWidth()/self.img.space:getWidth(),
    love.graphics.getHeight()/self.img.space:getHeight()
  )
  love.graphics.setBlendMode("add")
  love.graphics.draw(self.img.stars0, self.stars0_quad,
    -self.img.stars0:getWidth()+((x)%self.img.stars0:getWidth()),
    -self.img.stars0:getHeight()+((y)%self.img.stars0:getHeight()) )
  love.graphics.draw(self.img.stars1, self.stars1_quad,
    -self.img.stars1:getWidth()+((x/2)%self.img.stars1:getWidth()),
    -self.img.stars1:getHeight()+((y/2)%self.img.stars1:getHeight()) )
  love.graphics.setBlendMode("alpha")
end

function stars:drawPlanet()

  love.graphics.draw(stars.planet,
    love.graphics:getWidth() * 0.1,
    love.graphics:getHeight() * 0.75,
    love.timer.getTime() * 0.01,1,1,
    stars.planet:getWidth()/2,
    stars.planet:getHeight()/2)

end

return stars
