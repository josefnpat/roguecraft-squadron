local mainmenu = {}

function mainmenu:init()
  self.music = love.audio.newSource("assets/music/Terran4.ogg","stream")
  self.music:setVolume(0.65)
  self.music:setLooping(true)
  playBGM(self.music)
end

function mainmenu:enter()
  self.options = {
    {
      text = "New Easy Game",
      act = function()
        difficulty.mult.enemy = 1/2
        difficulty.mult.asteroid = 1
        libs.hump.gamestate.switch(states.game); states.game:init()
      end
    },
    {
      text = "New Medium Game",
      act = function()
        difficulty.mult.enemy = 2/2
        difficulty.mult.asteroid = 1+1/2
        libs.hump.gamestate.switch(states.game); states.game:init()
      end
    },
    {
      text = "New Hard Game",
      act = function()
        difficulty.mult.enemy = 3/2
        difficulty.mult.asteroid = 1+2/2
        libs.hump.gamestate.switch(states.game); states.game:init()
      end
    },
    {
      text = "New Insane Game",
      act = function()
        difficulty.mult.enemy = 4/2
        difficulty.mult.asteroid = 1+3/2
        libs.hump.gamestate.switch(states.game); states.game:init()
      end
    },
    {
      text = "Settings",
      act = function()
        libs.hump.gamestate.switch(states.options)
        settings.previousState = states.menu
      end
    },
    {
      text = "Credits",
      act = function()
        libs.hump.gamestate.switch(states.credits)
      end
    },
    {
      text = "Exit",
      act = function()
        love.event.quit()
      end
    },
  }

  self.hover_sound = love.audio.newSource("assets/sfx/hover.ogg")
  self.select_sound = love.audio.newSource("assets/sfx/select.ogg")

  self.raw_planet_images = love.filesystem.getDirectoryItems("assets/planets/")
  self.planet_images = {}
  for i = 1, #self.raw_planet_images do
    self.planet_images[i] = love.graphics.newImage("assets/planets/" .. self.raw_planet_images[i])
  end
  self.random_planet = math.random(#self.planet_images)
  self.planet_rotation = 0.01

  self.buttons_y = 1

  self.input_delay_timer = 0
  self.input_delay_max = 0.1
end

function mainmenu:update(dt)
  self.input_delay_timer = self.input_delay_timer + dt
  self.buttons_y = love.graphics:getHeight() / 4
  self.hovered_button = math.floor((love.mouse.getY() - self.buttons_y) / (fonts.menu:getHeight()))
  if love.mouse.isDown(1) then
    self.buttonpressed = self.hovered_button
    if self.options[self.buttonpressed] then
      if self.input_delay_timer > self.input_delay_max then
        self.options[self.buttonpressed].act()
        playSFX(self.select_sound)
      end
    end
  end

  if self.oldhovered_button ~= self.hovered_button and 
  self.hovered_button > 0 and
  self.hovered_button <= #self.options then
    playSFX(self.hover_sound)
  end

  self.oldhovered_button = self.hovered_button
end

function mainmenu:drawBackground()
  libs.stars:draw()
  love.graphics.draw(self.planet_images[self.random_planet],love.graphics:getWidth() * 0.1,love.graphics:getHeight() * 0.75,
    love.timer.getTime() * self.planet_rotation,1,1,
    self.planet_images[self.random_planet]:getWidth()/2,self.planet_images[self.random_planet]:getHeight()/2)
end

function mainmenu:draw()
  self:drawBackground()

  local y_offset = love.graphics:getHeight() * 0.075

  love.graphics.setFont(fonts.title)
  dropshadowf(game_name,0,y_offset + math.sin(love.timer.getTime()) * (y_offset / 4),love.graphics:getWidth(),"center")
  love.graphics.setFont(fonts.menu)
  for i = 1, #self.options do
    local current_text = self.options[i].text
    if self.hovered_button == i then current_text = "[" .. current_text .. "]" end
    dropshadowf(current_text ,0,math.floor(self.buttons_y) + i * fonts.menu:getHeight( ),love.graphics:getWidth(),"center")
  end
  love.graphics.setFont(fonts.default)
  love.graphics.print("GIT v"..git_count.." ["..git_hash.."]",32,32)
end

return mainmenu
