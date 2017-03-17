local mainmenu = {}

function mainmenu:init()
  self.music = love.audio.newSource("assets/music/Terran4.1.ogg","stream")
  self.music:setVolume(settings:read("music_vol",1))
  self.music:setLooping(true)
  self.music:play()
  self.logo = love.graphics.newImage("assets/logo.png")

  if love.filesystem.exists("demo.ogv") then
    self.demo = love.graphics.newVideo("demo.ogv")
  end

end

function mainmenu:enter()

  self.menum = libs.menu.new()--{title=game_name}

  self.menum:add("New Game",function()
    self.menu = self.menud
  end)

  self.menum:add("Options",function()
    libs.hump.gamestate.switch(states.options)
    previousState = states.menu
  end)

  self.menum:add("Credits",function()
    libs.hump.gamestate.switch(states.credits)
  end)

  self.menum:add("Exit",function()
    love.event.quit()
  end)

  self.menud = libs.menu.new()

  self.menud:add("Can I play, Daddy?",function()
    difficulty.mult.enemy = 1
    difficulty.mult.asteroid = 1
    difficulty.mult.scrap = 1
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menud:add("Don't hurt me.",function()
    difficulty.mult.enemy = 1.5
    difficulty.mult.asteroid = 0.75
    difficulty.mult.scrap = 0.5
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menud:add("Bring 'em on!",function()
    difficulty.mult.enemy = 2
    difficulty.mult.asteroid = 0.5
    difficulty.mult.scrap = 0.25
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menud:add("I am Death incarnate!",function()
    difficulty.mult.enemy = 2.5
    difficulty.mult.asteroid = 0.25
    difficulty.mult.scrap = 0.125
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menu = self.menum

  self.raw_planet_images = love.filesystem.getDirectoryItems("assets/planets/")
  self.planet_images = {}
  for i = 1, #self.raw_planet_images do
    self.planet_images[i] = love.graphics.newImage("assets/planets/" .. self.raw_planet_images[i])
  self.random_planet = math.random(#self.planet_images)
  self.planet_rotation = 0.01


  end

end

function mainmenu:update(dt)
  self.menu:update(dt)
  if self.demo then
    if not self.demo:isPlaying() then
      self.music:play()
    else
      self.music:pause()
    end
    self.demo_dt = (self.demo_dt or 0) + dt
  end
end

function mainmenu:draw()
  libs.stars:draw()

  love.graphics.draw(self.planet_images[self.random_planet],love.graphics:getWidth() * 0.1,love.graphics:getHeight() * 0.75,
    love.timer.getTime() * self.planet_rotation,1,1,
    self.planet_images[self.random_planet]:getWidth()/2,
    self.planet_images[self.random_planet]:getHeight()/2)

  local logox = (love.graphics.getWidth()-self.logo:getWidth())/2
  local logoy = love.graphics.getHeight()/16
  love.graphics.draw(self.logo,logox,logoy)

  self.menu:draw()

  love.graphics.setFont(fonts.default)
  love.graphics.print("GIT v"..git_count.." ["..git_hash.."]",32,32)

  if self.demo and self.demo_dt > 4 then
    self.demo:play()
    love.graphics.draw(self.demo,x,y,0,
      love.graphics.getWidth()/self.demo:getWidth(),
      love.graphics.getHeight()/self.demo:getHeight()
    )
  end
end

function mainmenu:mousemoved()
  if self.demo then
    self:stopDemo()
  end
end

function mainmenu:keypressed()
  if self.demo then
    self:stopDemo()
  end
end

function mainmenu:stopDemo()
  if self.demo:isPlaying() then
    self.demo:pause()
    self.demo:rewind()
  end
  self.demo_dt = nil
end

return mainmenu
