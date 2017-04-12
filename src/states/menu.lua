local mainmenu = {}

function mainmenu:init()
  self.music = love.audio.newSource("assets/music/Terran4.1.ogg","stream")
  self.music:setVolume(settings:read("music_vol"))
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
    local textstring = "Thank you for playing RogueCraft Squadron!\n\nWe're a very small team here at Missing Sentinel Software, and we appreciate any feedback we can get, good or bad!\n\nWould you be willing to take a short survey?"
    self.feedback = libs.window.new{
      x = (love.graphics.getWidth()-320)/2,
      title = "Help us out!",
      text = textstring,
      color = {255,127,255},
      buttons = {
        {
          text="SURE!",
          callback=function()
            love.system.openURL("http://roguecraftsquadron.com/feedback")
            love.event.quit()
          end,
        },
        {
          text="NO THANKS",
          callback=function()
            love.event.quit()
          end,
        },
      },
    }
    self.feedback.y = (love.graphics.getHeight()-self.feedback.h)/2
  end)

  self.menud = libs.menu.new()

  self.menud:add("Ensign (Easy)",function()
    difficulty.mult.enemy = 1
    difficulty.mult.asteroid = 1
    difficulty.mult.scrap = 1
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menud:add("Captain (Medium)",function()
    difficulty.mult.enemy = 1.5
    difficulty.mult.asteroid = 0.75
    difficulty.mult.scrap = 0.5
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menud:add("Colonel (Hard)",function()
    difficulty.mult.enemy = 2
    difficulty.mult.asteroid = 0.5
    difficulty.mult.scrap = 0.25
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menud:add("Admiral (Impossible)",function()
    difficulty.mult.enemy = 2.5
    difficulty.mult.asteroid = 0.25
    difficulty.mult.scrap = 0.125
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menu = self.menum

end

function mainmenu:update(dt)
  if self.feedback then
    self.feedback:update(dt)
  else
    self.menu:update(dt)
  end
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
  libs.stars:drawPlanet()

  local logox = (love.graphics.getWidth()-self.logo:getWidth())/2
  local logoy = (love.graphics.getHeight()-self.logo:getHeight())/2
  love.graphics.draw(self.logo,logox,logoy)

  self.menu:draw()

  if self.demo and self.demo_dt > 30 then
    self.demo:play()
    love.graphics.draw(self.demo,x,y,0,
      love.graphics.getWidth()/self.demo:getWidth(),
      love.graphics.getHeight()/self.demo:getHeight()
    )
  end

  if self.feedback then self.feedback:draw() end
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
