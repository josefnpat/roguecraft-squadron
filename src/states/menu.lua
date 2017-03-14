local mainmenu = {}

function mainmenu:init()
  self.music = love.audio.newSource("assets/music/Terran4.ogg","stream")
  self.music:setVolume(settings:read("music_vol",1))
  self.music:setLooping(true)
  self.music:play()
end

function mainmenu:enter()

  self.menu = libs.menu.new{title=game_name}

  self.menu:add("New Easy Game",function()
    difficulty.mult.enemy = 1/2
    difficulty.mult.asteroid = 1
    libs.hump.gamestate.switch(states.mission); states.mission:init()
  end)

  self.menu:add("New Medium Game",function()
    difficulty.mult.enemy = 2/2
    difficulty.mult.asteroid = 1+1/2
    libs.hump.gamestate.switch(states.mission); states.mission:init()
  end)

  self.menu:add("New Hard Game",function()
    difficulty.mult.enemy = 3/2
    difficulty.mult.asteroid = 1+2/2
    libs.hump.gamestate.switch(states.mission); states.mission:init()
  end)

  self.menu:add("New Insane Game",function()
    difficulty.mult.enemy = 4/2
    difficulty.mult.asteroid = 1+3/2
    libs.hump.gamestate.switch(states.mission); states.mission:init()
  end)

  self.menu:add("Options",function()
    libs.hump.gamestate.switch(states.options)
    previousState = states.menu
  end)

  self.menu:add("Credits",function()
    libs.hump.gamestate.switch(states.credits)
  end)

  self.menu:add("Exit",function()
    love.event.quit()
  end)

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
end

function mainmenu:draw()
  libs.stars:draw()
  love.graphics.draw(self.planet_images[self.random_planet],love.graphics:getWidth() * 0.1,love.graphics:getHeight() * 0.75,
    love.timer.getTime() * self.planet_rotation,1,1,
    self.planet_images[self.random_planet]:getWidth()/2,
    self.planet_images[self.random_planet]:getHeight()/2)

  self.menu:draw()

  love.graphics.setFont(fonts.default)
  love.graphics.print("GIT v"..git_count.." ["..git_hash.."]",32,32)
end

return mainmenu
