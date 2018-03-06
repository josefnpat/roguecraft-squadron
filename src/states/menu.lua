local mainmenu = {}

function mainmenu:init()

  self.music = {}

  self.music.title = love.audio.newSource("assets/music/Terran4.1.ogg","stream")
  self.music.title:setVolume(settings:read("music_vol"))
  self.music.title:setLooping(true)

  self.music.game = love.audio.newSource("assets/music/Terran4.1.ogg","stream")
  self.music.game:setVolume(settings:read("music_vol"))
  self.music.game:setLooping(true)

  self.music.title:play()

  self.logo = love.graphics.newImage("assets/logo.png")

  self.debug_menu = {"up","up","down","down","left","right","left","right","b","a"}
  self.debug_menu_index = 1

end

function mainmenu:setDifficulty(diff)

  if diff == "easy" then
    difficulty.mult.enemy = 1
    difficulty.mult.asteroid = 1
    difficulty.mult.scrap = 1
  elseif diff == "medium" then
    difficulty.mult.enemy = 1.5
    difficulty.mult.asteroid = 0.75
    difficulty.mult.scrap = 0.5
  elseif diff== "hard" then
    difficulty.mult.enemy = 2
    difficulty.mult.asteroid = 0.5
    difficulty.mult.scrap = 0.25
  else -- if diff == insane
   -- hide yo children, hide yo wife, hope your settings ain't fucked
    difficulty.mult.enemy = 2.5
    difficulty.mult.asteroid = 0.25
    difficulty.mult.scrap = 0.125
  end

end


function mainmenu:enter()

  if love.filesystem.exists("demo.ogv") then
    self.demo = love.graphics.newVideo("demo.ogv")
  end

  self.menum = libs.menu.new()--{title=game_name}

  if settings:read("diff") ~= "new" then
    --TODO: i18n
    self.menum:add(
      libs.i18n('menu.continue_game').." ("..settings:read("diff")..")",
      function()
        mainmenu:setDifficulty(settings:read("diff"))
        states.mission.newGame = true
        libs.hump.gamestate.switch(states.disclaimer)
      end
    )
  end

  self.menum:add(libs.i18n('menu.new_game'),function()
    settings:write("tree_points",0)
    settings:write("tree_levels",{})
    self.menu = self.menud
  end)

  self.menum:add(libs.i18n('menu.options'),function()
    libs.hump.gamestate.switch(states.options)
    previousState = states.menu
  end)

  if self.debug_menu_enabled then
    self.menum:add(libs.i18n('menu.debug'),function()
      libs.hump.gamestate.switch(states.debug)
    end)
  end

  self.menum:add(libs.i18n('menu.credits'),function()
    libs.hump.gamestate.switch(states.credits)
  end)

  self.menum:add(libs.i18n('menu.exit'),function()
    self.feedback = libs.window.new{
      x = (love.graphics.getWidth()-320)/2,
      title = libs.i18n('menu.survey.title'),
      text = libs.i18n('menu.survey.body'),
      buttons = {
        {
          text=libs.i18n('menu.survey.yes'),
          callback=function()
            love.system.openURL("http://roguecraftsquadron.com/feedback?git="..git_count.." ["..git_hash.."]")
            love.event.quit()
          end,
        },
        {
          text=libs.i18n('menu.survey.no'),
          callback=function()
            love.event.quit()
          end,
        },
      },
    }
    self.feedback.y = (love.graphics.getHeight()-self.feedback.h)/2
  end)

  self.menud = libs.menu.new()

  -- TODO: i18n
  self.menud:add("Ensign (Easy)",function()
    mainmenu:setDifficulty("easy")
    settings:write("diff","easy")
    states.mission.newGame = true
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menud:add("Captain (Medium)",function()
    mainmenu:setDifficulty("medium")
    settings:write("diff","medium")
    states.mission.newGame = true
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menud:add("Colonel (Hard)",function()
    mainmenu:setDifficulty("hard")
    settings:write("diff","hard")
    states.mission.newGame = true
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menud:add("Admiral (Impossible)",function()
    mainmenu:setDifficulty("impossible")
    settings:write("diff","immpossible")
    states.mission.newGame = true
    libs.hump.gamestate.switch(states.disclaimer)
  end)

  self.menud:add(libs.i18n('menu.back'),function()
    self.menu = self.menum
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
      self.music.game:play()
    else
      self.music.game:pause()
    end
    self.demo_dt = (self.demo_dt or 0) + dt
  end
end

function mainmenu:draw()

  libs.stars:draw()
  libs.stars:drawPlanet()

  local logow = love.graphics.getWidth()*11/16 -- see menu lib for this math

  local logox = (logow-self.logo:getWidth())/2
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

  libs.version.draw()

end

function mainmenu:mousemoved()
  if self.demo then
    self:stopDemo()
  end
end

function mainmenu:keypressed(key)
  if self.debug_menu[self.debug_menu_index] == key then
    self.debug_menu_index = self.debug_menu_index + 1
    if self.debug_menu_index == #self.debug_menu + 1 then
      self.debug_menu_enabled = not self.debug_menu_enabled
      self.debug_menu_index = 1
      self:enter()
      print(libs.i18n('menu.debug_enabled'))
    end
  else
    self.debug_menu_index = 1
  end
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
