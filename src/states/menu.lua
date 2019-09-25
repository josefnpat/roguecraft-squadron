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

  -- windows
  self.windows = libs.windowmanager.new()
  self.mpserverlist = libs.mpserverlist.new()
  self.windows:add(self.mpserverlist,"mpserverlist")

  if stress_score > stress_score_min then
    self.stress = libs.window.new{
      x = (love.graphics.getWidth()-320)/2,
      title = "Performance Warning!",
      text = "Stress Score: "..stress_score..
        "\nSuggested Score: "..stress_score_min..
        "\n\nStress testing has detected that the current machine load may lead to poor performance."..
        "\n\nUnexpected issues may occur due to poor performance.",
      buttons = {
        {
          text="OK",--libs.i18n('menu.survey.yes'),
          callback=function()
            self.stress = nil
          end,
        },
      },
    }
    self.stress.y = (love.graphics.getHeight()-self.stress.h)/2
  end

end

function mainmenu:connectToServer(ip,port)
  local name = settings:read("user_name")
  settings:write("remote_server_address",ip)
  settings:write("server_port",port)
  states.client._remote_address = ip
  game_singleplayer = false
  self.music.title:stop()
  libs.hump.gamestate.switch(states.client)
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

  self.menu_main = libs.menu.new()--{title=game_name}

  self.menu_main:addButton(
    libs.i18n('menu.singleplayer'),
    function()
      states.client._remote_address = nil
      game_singleplayer = true
      states.server:init()
      if states.server.run_localhost then
        states.server:leave()
      end
      states.server.run_localhost = true
      self.music.title:stop()
      libs.hump.gamestate.switch(states.client)
    end)

  self.menu_main:addButton(
    libs.i18n('menu.multiplayer'),
    function()
      self.menu = self.menu_mp
    end)

  self.menu_main:addButton(
    libs.i18n('menu.options'),
    function()
      libs.hump.gamestate.switch(states.options)
    end)

  if self.debug_menu_enabled then
    self.menu_main:addButton(libs.i18n('menu.debug'),function()
      libs.hump.gamestate.switch(states.debug)
    end)
  end

  self.menu_main:addButton(
    libs.i18n('menu.credits'),
    function()
      libs.hump.gamestate.switch(states.credits)
    end)

  self.menu_main:addButton(
    libs.i18n('menu.feedback'),
    function()
      self.feedback = libs.window.new{
        x = (love.graphics.getWidth()-320)/2,
        title = libs.i18n('menu.survey.title'),
        text = libs.i18n('menu.survey.body'),
        buttons = {
          {
            text=libs.i18n('menu.survey.yes'),
            callback=function()
              love.system.openURL("http://roguecraftsquadron.com/feedback?git="..git_count.." ["..git_hash.."]")
              self.feedback = nil
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

  self.menu_main:addButton(
    libs.i18n('menu.exit'),
    function()
      if isRelease() then
        love.event.quit()
      else
        self.demosplash = libs.demosplash.new()
      end
    end)

  self.menu_mp = libs.menu.new()

  local ask_mask = function(asset)
    if settings:read('sensitive') then
      return string.rep("*",string.len(asset))
    else
      return asset
    end
  end

  local ask_for_name = function(callback)
    self.chooser = libs.stringchooser.new{
      prompt = "Set User Name:",
      string = settings:read("user_name"),
      callback = function(string)
        self.chooser = nil
        settings:write("user_name",string)
        callback()
      end,
      cancelCallback = function()
        self.chooser = nil
      end,
    }
  end

  local ask_for_servername = function(callback)
    self.chooser = libs.stringchooser.new{
      prompt = "Set Server Name:",
      string = settings:read("user_name") .. "'s Game",
      callback = function(string)
        self.chooser = nil
        settings:write("server_name",string)
        callback()
      end,
      cancelCallback = function()
        self.chooser = nil
      end,
    }
  end

  local ask_for_ip = function(callback)
    self.chooser = libs.stringchooser.new{
      prompt = "Server IP Address:",
      string = settings:read("remote_server_address"),
      callback = function(string)
        self.chooser = nil
        settings:write("remote_server_address",string)
        callback()
      end,
      cancelCallback = function()
        self.chooser = nil
      end,
      validate = function(asset)
        return libs.acf.validator.is_ipv4(asset)
      end,
      mask = ask_mask,
    }
  end

  local ask_for_port = function(callback)
    self.chooser = libs.stringchooser.new{
      prompt = "Server Port:",
      string = settings:read("server_port"),
      callback = function(string)
        self.chooser = nil
        settings:write("server_port",string)
        callback()
      end,
      cancelCallback = function()
        self.chooser = nil
      end,
      validate = function(asset)
        return libs.acf.validator.is_port(asset)
      end,
      mask = ask_mask,
    }
  end

  local ask_for_host = function(callback)
    ask_for_name(function()
      ask_for_servername(function()
        ask_for_port(callback)
      end)
    end)
  end

  self.menu_mp:addButton(
    libs.i18n('menu.host'),
    function()
      ask_for_host(function()
        states.client._remote_address = nil
        game_singleplayer = false
        states.server:init()
        states.server.run_localhost = true
        self.music.title:stop()
        libs.hump.gamestate.switch(states.client)
      end)
    end)

  if isRelease() then
    self.menu_mp:addButton(
      libs.i18n('menu.serverlist'),
      function()
        ask_for_name(function()
          self.mpserverlist:setActive(true)
        end)
      end)
  end

  local ask_for_client = function(callback)
    ask_for_name(function()
      ask_for_ip(function()
        ask_for_port(callback)
      end)
    end)
  end
  self.menu_mp:addButton(
    libs.i18n('menu.client'),
    function()
      ask_for_client(function()
        states.client._remote_address = settings:read("remote_server_address")
        game_singleplayer = false
        self.music.title:stop()
        libs.hump.gamestate.switch(states.client)
      end)
    end)

  if debug_mode then
    local ask_for_host_dedicated = function(callback)
      ask_for_port(callback)
    end
    self.menu_mp:addButton(
      libs.i18n('menu.host_dedicated'),
      function()
        ask_for_host_dedicated(function()
          game_singleplayer = false
          libs.hump.gamestate.switch(states.server)
        end)
      end)
  end

  self.menu_mp:addButton(
    libs.i18n('menu.help'),
    function()
      love.system.openURL( "https://github.com/josefnpat/roguecraft-squadron/wiki/Multiplayer" )
    end)

  self.menu_mp:addButton(
    libs.i18n('menu.back'),
    function()
      self.chooser = nil
      self.menu = self.menu_main
    end)

  self.menu = self.menu_main

  self.windows:hide()

end

function mainmenu:leave()
  libs.demo:unload()
end

function mainmenu:update(dt)
  if self.windows:isActive() then
    self.mpserverlist:update(dt)
  elseif self.demosplash then
    self.demosplash:update(dt)
  elseif self.stress then
    self.stress:update(dt)
  elseif self.feedback then
    self.feedback:update(dt)
  else
    self.menu:update(dt)
    self.social:update(dt)
    libs.demo:update(dt)
    if self.chooser then
      self.chooser:update(dt)
    end
  end
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
  if self.stress then self.stress:draw() end
  if self.feedback then self.feedback:draw() end
  if self.demosplash then
    self.demosplash:draw()
  end
  libs.version.draw()
  self.social:draw()
  if self.windows:isActive() then
    self.mpserverlist:draw()
  end
  if self.chooser then
    self.chooser:draw()
  end

  libs.demo:draw()

end

function mainmenu:mousemoved()
  libs.demo:stop()
end

function mainmenu:keypressed(key)

  if key == "escape" then
    if self.stress then
      self.stress = nil
    elseif self.feedback then
      self.feedback = nil
    elseif self.windows:isActive() then
      self.windows:hide()
    elseif self.chooser then
      self.chooser = nil
    elseif self.menu ~= self.menu_main then
      self.menu = self.menu_main
    end
  end

  if not self.windows:isActive() then

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
end

return mainmenu
