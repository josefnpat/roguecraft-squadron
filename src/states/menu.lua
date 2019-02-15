local mainmenu = {}

function mainmenu:init()

  self.music = {}

  self.music.title = love.audio.newSource("assets/music/Menu.ogg","stream")
  self.music.title:setVolume(settings:read("music_vol"))
  self.music.title:setLooping(true)

  self.logo = love.graphics.newImage("assets/logo.png")
  self.tagline = love.graphics.newImage("assets/tagline.png")

  self.debug_menu = {"up","up","down","down","left","right","left","right","b","a"}
  self.debug_menu_index = 1

  self.social = libs.social.new()

end

function mainmenu:textinput(t)
  if self.chooser then
    self.chooser:textinput(t)
  end
end

function mainmenu:enter()

  libs.cursor.change("default")

  self.music.title:play()

  libs.demo:check()

  self.menum = libs.menu.new()--{title=game_name}

  self.menum:addButton(libs.i18n('menu.multiplayer'),function()
      self.menu = self.menump
    end
  )

  self.menum:addButton(libs.i18n('menu.options'),function()
    libs.hump.gamestate.switch(states.options)
  end)

  if self.debug_menu_enabled then
    self.menum:addButton(libs.i18n('menu.debug'),function()
      libs.hump.gamestate.switch(states.debug)
    end)
  end

  self.menum:addButton(libs.i18n('menu.credits'),function()
    libs.hump.gamestate.switch(states.credits)
  end)

  self.menum:addButton(libs.i18n('menu.feedback'),function()
    self.feedback = libs.window.new{
      x = (love.graphics.getWidth()-320)/2,
      title = libs.i18n('menu.survey.title'),
      text = libs.i18n('menu.survey.body'),
      buttons = {
        {
          text=libs.i18n('menu.survey.yes'),
          callback=function()
            love.system.openURL("http://roguecraftsquadron.com/feedback?git="..git_count.." ["..git_hash.."]")
          end,
        },
        {
          text=libs.i18n('menu.survey.no'),
          callback=function()
            self.feedback = nil
          end,
        },
      },
    }
    self.feedback.y = (love.graphics.getHeight()-self.feedback.h)/2
  end)

  self.menum:addButton(libs.i18n('menu.exit'),function()
    if isRelease() then
      love.event.quit()
    else
      self.demosplash = libs.demosplash.new()
    end
  end)

  self.menump = libs.menu.new()

  self.menump:addButton(
    function()
      return libs.i18n('menu.server')
    end,
    function()
      states.client._remote_address = nil
      states.server:init()
      if states.server.run_localhost then
        states.server:leave()
      end
      states.server.run_localhost = true
      self.music.title:stop()
      libs.hump.gamestate.switch(states.client)
    end
  )

  self.menump:addButton(
    function()
      return libs.i18n('menu.client') .. " ["..settings:read("remote_server_address").."]"
    end,
    function()
      states.client._remote_address = settings:read("remote_server_address")
      self.music.title:stop()
      libs.hump.gamestate.switch(states.client)
    end
  )

  self.menump:addButton(
    function()
      return libs.i18n('menu.remote_server_address')
    end,
    function()
      self.chooser = libs.stringchooser.new{
        prompt = "Set Remote Server Address:",
        string = settings:read("remote_server_address"),
        callback = function(string)
          self.chooser = nil
          settings:write("remote_server_address",string)
        end,
      }
    end
  )

  self.menump:addButton(
    function()
      return libs.i18n('menu.user_name').." ["..settings:read("user_name").."]"
    end,
    function()
      self.chooser = libs.stringchooser.new{
        prompt = "Set User Name:",
        string = settings:read("user_name"),
        callback = function(string)
          self.chooser = nil
          settings:write("user_name",string)
        end,
      }
    end
  )

  self.menump:addButton(
    function()
      return libs.i18n('menu.standalone_server')
    end,
    function()
      libs.hump.gamestate.switch(states.server)
    end
  )

  self.menump:addButton(
    function()
      return libs.i18n('menu.client') .. ' [localhost]'
    end,
    function()
      states.client._remote_address = nil
      self.music.title:stop()
      libs.hump.gamestate.switch(states.client)
    end
  )

  self.menump:addButton(libs.i18n('menu.back'),function()
      self.chooser = nil
      self.menu = self.menum
    end
  )

  self.menu = self.menum

end

function mainmenu:leave()
  libs.demo:unload()
end

function mainmenu:update(dt)
  if self.demosplash then
    self.demosplash:update(dt)
  elseif self.feedback then
    self.feedback:update(dt)
  else
    self.menu:update(dt)
  end
  libs.demo:update(dt)
  self.social:update(dt)
end

function mainmenu:draw()

  libs.stars:draw()
  libs.stars:drawPlanet()

  if not debug_hide_hud then
    local logox = love.graphics.getWidth()/16
    local logow = love.graphics.getWidth()*9/16 -- see menu lib for this math
    local logoy = (love.graphics.getHeight()-self.logo:getHeight())/2
    love.graphics.draw(self.logo,logox+(logow-self.logo:getWidth())/2,logoy)
    love.graphics.draw(self.logo,logox-(self.logo:getWidth()-logow)/2,logoy)
    love.graphics.draw(self.tagline,
      logox+(logow-self.tagline:getWidth())/2,
      logoy+self.logo:getHeight()
    )
  end

  self.menu:draw()

  if self.feedback then self.feedback:draw() end

  if self.demosplash then
    self.demosplash:draw()
  end

  libs.version.draw()

  if self.chooser then
    self.chooser:draw()
  end

  self.social:draw()

  libs.demo:draw()

end

function mainmenu:mousemoved()
  libs.demo:stop()
end

function mainmenu:keypressed(key)

  if key == "escape" then
    if self.chooser then
      self.chooser = nil
    elseif self.menu ~= self.menum then
      self.menu = self.menum
    end
  end

  if self.chooser then
    self.chooser:keypressed(key)
  end

  if self.debug_menu[self.debug_menu_index] == key then
    self.debug_menu_index = self.debug_menu_index + 1
    if self.debug_menu_index == #self.debug_menu + 1 then
      self.debug_menu_enabled = not self.debug_menu_enabled
      self.debug_menu_index = 1
      self:enter()
      print(libs.i18n('menu.debug_enabled'))
      libs.sfx.play("silly")
    end
  else
    self.debug_menu_index = 1
  end
  libs.demo:stop()
end

return mainmenu
