local mpconnect = {}

mpconnect.icons = {
  check = love.graphics.newImage("assets/hud/check.png"),
  check_empty = love.graphics.newImage("assets/hud/check_empty.png"),
}

function mpconnect.new(init)
  init = init or {}
  local self = {}

  self.lovernet = init.lovernet
  self.chat = init.chat
  self.ai_count = init.ai_count or 1
  self.creative = false
  self.everyShipUnlocked = false
  self.preset = init.preset or #libs.mppresets.getPresets()
  self.transmitRate = init.transmitRate or 1
  self.levelSelect = init.levelSelect or 1
  self.points = init.points or 1
  self.mpgamemodes = init.mpgamemodes
  self.guide = libs.guide.new()

  self.generateButtons = mpconnect.generateButtons
  self.getPublicIPString = mpconnect.getPublicIPString
  self.updateData = mpconnect.updateData
  self.update = mpconnect.update
  self.draw = mpconnect.draw
  self.setAiCount = mpconnect.setAiCount
  self.setCreative = mpconnect.setCreative
  self.setEveryShipUnlocked = mpconnect.setEveryShipUnlocked
  self.setPreset = mpconnect.setPreset
  self.setPoints = mpconnect.setPoints
  self.setMap = mpconnect.setMap
  self.setMapSize = mpconnect.setMapSize
  self.setMapGenDefault = mpconnect.setMapGenDefault
  self.setMapPockets = mpconnect.setMapPockets
  self.setGamemode = mpconnect.setGamemode
  self.setTransmitRate = mpconnect.setTransmitRate
  self.setLevelSelect = mpconnect.setLevelSelect
  self.setUser = mpconnect.setUser
  self.validateVersion = mpconnect.validateVersion

  self._players = {}
  self._data = {}

  self.openMenu = libs.button.new{
    text="Menu",
    onClick=function()
      -- LOL, fuck you future seppi.
      states.client:keypressed("escape")
    end,
    tooltip="Open the game menu.",
    width=128,
  }

  self.start = libs.button.new{
    text="Ready",
    onClick=function()
      local player = libs.net.getPlayerById(self._players,self._user_id)
      self.lovernet:pushData(libs.net.op.set_players,{
        d={ready=not player.ready},
        p=self._user_id,
        t="u"})
    end,
    icon=function()
      local player = libs.net.getPlayerById(self._players,self._user_id)
      return player.ready and mpconnect.icons.check or mpconnect.icons.check_empty
    end,
    tooltip="Change your ready status.",
  }

  self.gamemodes = {}
  for _,gamemode in pairs(self.mpgamemodes:getGamemodes()) do
    local gamemode_button = libs.button.new{
      text=gamemode.name,
      onClick=function()
        self.target_gamemode = gamemode.id
      end,
    }
    table.insert(self.gamemodes,gamemode_button)
  end

  self.gamemodeTargetButton = libs.button.new{
    text="Start",
    onClick=function()
      self.lovernet:pushData(libs.net.op.set_config,{d={gamemode=self.target_gamemode}})
    end,
  }

  return self
end

function mpconnect:getPublicIPString()
  local r, e = require("socket.http").request("http://ifconfig.co/ip")
  local wan = e == 200 and r or "No Internet Connection"

  local socket = require("socket")
  local mySocket = socket.udp()
  mySocket:setpeername("10.0.0.1","9000")
  local lan, lan_port = mySocket:getsockname()-- returns IP and Port
  return "LAN: " .. lan .. " / WAN: " .. wan
end

function mpconnect:generateButtons()

  self.buttons = {}

  if not game_singleplayer then

    local publicIPString

    self.showPublicIPButton = libs.button.new{
      text=function()
        return publicIPString or "Click to show IP"
      end,
      onClick=function()
        if publicIPString then
          publicIPString = nil
        else
          publicIPString = self:getPublicIPString()
        end
      end,
    }
    table.insert(self.buttons,self.showPublicIPButton)

    self.transmitRatesButton = libs.stepper.new{
      text="Network",
      onClick=function(dir)
        self.lovernet:pushData(libs.net.op.set_config,{d={transmitRate=self.transmitRate+dir}})
      end,
      tooltip="Change the update time per player. Raise this if your game has issues.",
    }
    table.insert(self.buttons,self.transmitRatesButton)

  end

  -- todo: add when there's a way to reset the server config
  --[[
  self.changeGameModeButton = libs.button.new{
    text="Change Game Mode",
    onClick=function()
      self.lovernet:pushData(libs.net.op.set_config,{d={gamemode="nil"}})
    end,
  }
  table.insert(self.buttons,self.changeGameModeButton)
  --]]

  local gamemode_object = self.mpgamemodes:getGamemodeById(self.gamemode)

  if gamemode_object.configurable then

    self.presetButton = libs.stepper.new{
      disabled=#libs.mppresets.getPresets()<=1,
      text="Preset",
      onClick=function(dir)
        self.lovernet:pushData(libs.net.op.set_config,{d={preset=self.preset+dir}})
      end,
      tooltip="Change what ships are available in the game.",
    }
    table.insert(self.buttons,self.presetButton)

    self.aiCountButton = libs.stepper.new{
      text="AI Count",
      onClick=function(dir)
        self.lovernet:pushData(libs.net.op.set_config,{d={ai=self.ai_count+dir}})
      end,
      tooltip="Change how many computers you want playing in the game.",
    }
    table.insert(self.buttons,self.aiCountButton)

    table.insert(self.buttons,libs.button.new{
      disabled=not isRelease(),
      text=function() return self.creative and "Build Mode [Creative]" or "Build Mode [Normal]" end,
      onClick=function()
        self.lovernet:pushData(libs.net.op.set_config,{d={creative=not self.creative}})
      end,
      tooltip="Change how long it takes to build ships.",
    })

    table.insert(self.buttons,libs.button.new{
      disabled=not isRelease(),
      text=function() return self.everyShipUnlocked and "Research [All Unlocked]" or "Research [Normal]" end,
      onClick=function()
        self.lovernet:pushData(libs.net.op.set_config,{d={everyShipUnlocked=not self.everyShipUnlocked}})
      end,
      tooltip="Determine if all ships are unlocked in the game.",
    })

    self.pointsButton = libs.stepper.new{
      disabled=not isRelease(),
      text="Points",
      onClick=function(dir)
        self.lovernet:pushData(libs.net.op.set_config,{d={points=self.points+dir}})
      end,
      tooltip="Determine how many ships can be made in a game by choosing a command capacity.",
    }
    table.insert(self.buttons,self.pointsButton)

    self.mapButton = libs.stepper.new{
      disabled=not isRelease(),
      text="Maps",
      onClick=function(dir)
        self.lovernet:pushData(libs.net.op.set_config,{d={map=self.map+dir}})
      end,
      tooltip="Choose what kind of map the game will use.",
    }
    table.insert(self.buttons,self.mapButton)

    self.mapSizeButton = libs.stepper.new{
      disabled=not isRelease(),
      text="Map Size",
      onClick=function(dir)
        self.lovernet:pushData(libs.net.op.set_config,{d={mapsize=self.mapsize+dir}})
      end,
      tooltip="Choose the size of the map for the game.",
    }
    table.insert(self.buttons,self.mapSizeButton)

    self.mapPocketsButton = libs.stepper.new{
      disabled=not isRelease(),
      text="Resource Pockets",
      onClick=function(dir)
        self.lovernet:pushData(libs.net.op.set_config,{d={mapPockets=self.mapPockets+dir}})
      end,
      tooltip="Choose among how many pockets the resources are spread out on. Only works for Map Type Spaced Pockets.",
    }
    table.insert(self.buttons,self.mapPocketsButton)

    self.mapGenDefaultButton = libs.stepper.new{
      disabled=not isRelease(),
      text="Resources",
      onClick=function(dir)
        self.lovernet:pushData(libs.net.op.set_config,{d={mapGenDefault=self.mapGenDefault+dir}})
      end,
      tooltip=" Choose how many resources are available on the map.",
    }
    table.insert(self.buttons,self.mapGenDefaultButton)

  end

  self.levelSelectButton = libs.stepper.new{
    text="Level Select",
    onClick=function(dir)
      --todo: fix this
      self.lovernet:pushData(libs.net.op.set_config,{d={levelSelect=self.levelSelect+dir}})
    end,
    tooltip="Change the level you start on.",
  }
  table.insert(self.buttons,self.levelSelectButton)

  for _,button in pairs(self.buttons) do
    button:setFont(fonts.submenu)
    button:setHeight(32)
  end

end

function mpconnect:updateData(config,players)
  if not compareIndexed(players,self._players) then
    self._players = players
    self._data = {}
    for player_index,player in pairs(players) do
      local type = player.ai == nil and "user" or "ai"
      local user_name = player.ai == nil and player.user_name or "[AI]"
      local player_type_id = player.ai == nil and player.id or player.ai
      local player_data = libs.mpconnectplayer.new{
        type=type,
        user_name=user_name,
        user_id=player_type_id,
        ready=player.ready,
        player_index=player_index,
        team=player.team,
        race=player.race,
        diff=player.diff,
        lovernet = self.lovernet,
      }
      table.insert(self._data,player_data)
    end
  end
end

function mpconnect:update(dt)

  self.openMenu:update(dt)

  if self.gamemode == nil then
    for _,button in pairs(self.gamemodes) do
      button:update(dt)
    end
    self.gamemodeTargetButton:update(dt)
  else

    local gamemode_object = self.mpgamemodes:getGamemodeById(self.gamemode)
    for _,player_data in pairs(self._data) do
      player_data:setConfigurableTeam(gamemode_object.configurable_team)
      player_data:setConfigurableRace(gamemode_object.configurable_race)
      player_data:setConfigurableDiff(gamemode_object.configurable_diff)
    end
    self.start:update(dt)
    self.chat:smallHeight()
    for _,button in pairs(self.buttons) do
      button:update(dt)
    end
    for _,player_data in pairs(self._data) do
      player_data:update(dt)
    end
  end
end

function mpconnect:setAiCount(count)
  self.ai_count = count
  if self.aiCountButton then
    self.aiCountButton:setText("AI Count ["..self.ai_count.."]")
  end
end

function mpconnect:setCreative(val)
  self.creative = val
end

function mpconnect:setEveryShipUnlocked(val)
  self.everyShipUnlocked = val
end

function mpconnect:setPreset(preset_value)
  self.preset = preset_value
  local preset = libs.mppresets.getPresets()[preset_value]
  if self.presetButton then
    self.presetButton:setText(preset.name)
  end
end

function mpconnect:setPoints(points_value)
  self.points = points_value
  if self.pointsButton then
    self.pointsButton:setText("Command Cap ["..libs.net.points[points_value].text.."]")
  end
end

function mpconnect:setMap(map_value)
  self.map = map_value
  if self.mapButton then
    self.mapButton:setText("Map Type ["..libs.net.maps[map_value].text.."]")
  end
end

function mpconnect:setMapSize(map_size_value)
  self.mapsize = map_size_value
  if self.mapSizeButton then
    self.mapSizeButton:setText("Map Size ["..libs.net.mapSizes[map_size_value].text.."]")
  end
end

function mpconnect:setMapGenDefault(map_gen_default)
  self.mapGenDefault = map_gen_default
  if self.mapGenDefaultButton then
    self.mapGenDefaultButton:setText("Resources ["..libs.net.mapGenDefaults[map_gen_default].text.."]")
  end
end

function mpconnect:setMapPockets(map_pockets)
  self.mapPockets = map_pockets
  if self.mapPocketsButton then
    self.mapPocketsButton:setText("Resource Pockets ["..self.mapPockets.."]")
  end
end

function mpconnect:setGamemode(gamemode)
  local gamemode_object = self.mpgamemodes:getGamemodeById(gamemode)
  local previous_gamemode = self.gamemode
  self.gamemode = gamemode
  if self.gamemode ~= previous_gamemode then
    self:generateButtons()
    self.mpgamemodes:setCurrentGamemode(gamemode_object)
  end
  local gamemode_object = self.mpgamemodes:getGamemodeById(gamemode)
end

function mpconnect:setTransmitRate(value)
  self.transmitRate = value
  if self.transmitRatesButton then
    self.transmitRatesButton:setText("Network ["..libs.net.transmitRates[value].text.."]")
  end
end

function mpconnect:setLevelSelect(value)
  self.levelSelect = value
  if self.levelSelectButton then
    --todo: load level data, and determine level
    self.levelSelectButton:setText("Select Level ["..(1).."]")
  end
end

function mpconnect:setUser(user_id)
  self._user_id = user_id
end

function mpconnect:validateVersion(server_git_hash,server_git_count)
  self._valid = git_hash==server_git_hash and git_count==server_git_count
  if self._valid == false then
    self._valid_msg = ""
    self._valid_msg = self._valid_msg .. "Client Hash: "..tostring(git_hash) .. "\n"
    self._valid_msg = self._valid_msg .. "Client Version: "..tostring(git_count) .. "\n"
    self._valid_msg = self._valid_msg .. "Server Hash: "..tostring(server_git_hash) .. "\n"
    self._valid_msg = self._valid_msg .. "Server Version: "..tostring(server_git_count) .. "\n"
  end
end

function mpconnect:draw(config,players,user_count)

  libs.backgroundlib.draw()

  if debug_mode then
    local s = ""
    s = s .. "user_count: " .. user_count .. "\n"
    s = s .. "get_config:\n"
    if config then
      for i,v in pairs(config) do
        s = s .. "\t" .. i .. ": "..tostring(v) .. "\n"
      end
    end
    s = s .. "get_players:\n"
    if players then
      for i,player in pairs(players) do
        s = s .. "\tplayer[" .. i .. "]: "..tostring(player) .. "\n"
        for i,v in pairs(player) do
          s = s .. "\t\t" .. i .. ": "..tostring(v) .. "\n"
        end
      end
    else
      s = s .. "no player data"
    end
    love.graphics.print(s,32,256)
  end

  if self._valid == nil then

    libs.loading.draw("Connecting ...")

  elseif self._valid == false then

    libs.loading.draw("Error: Client and server version do not match.\n"..self._valid_msg)

  elseif self._valid == true then

    if #self._data == 0 then

      libs.loading.draw("Waiting for server to respond ...")

    elseif self.gamemode == nil then

      local paddingHorizontal = 32
      local paddingVertical = 4

      local buttonWidth = 256
      local buttonHeight = 40

      local bx = (love.graphics.getWidth() - buttonWidth)/2
      local by = (love.graphics.getHeight() - buttonHeight*#self.mpgamemodes:getGamemodes())/2

      if self.target_gamemode then

        local gamemode_object = self.mpgamemodes:getGamemodeById(self.target_gamemode)
        local gx = (love.graphics.getWidth() - gamemode_object.image:getWidth() - buttonWidth - paddingHorizontal)/2
        bx = gx + gamemode_object.image:getWidth() + paddingHorizontal


        local name_height = fonts.title:getHeight()
        local image_height = gamemode_object.image:getHeight()
        local desc_height = fonts.default:getHeight() -- w/e i'm lazy
        by = (love.graphics.getHeight() - name_height - image_height - desc_height)/2
        love.graphics.draw(gamemode_object.image,gx,by)
        love.graphics.setFont(fonts.title)
        dropshadow(gamemode_object.name,gx,by+image_height)
        love.graphics.setFont(fonts.default)
        dropshadowf(gamemode_object.desc:gsub("\n"," "),gx,by+image_height+name_height,gamemode_object.image:getWidth())

        local targetVerticalOffset = (name_height - buttonHeight)/2

        self.gamemodeTargetButton:setX(gx+gamemode_object.image:getWidth()-buttonWidth)
        self.gamemodeTargetButton:setY(by+gamemode_object.image:getHeight()+targetVerticalOffset+paddingVertical)
        self.gamemodeTargetButton:setWidth(buttonWidth)
        self.gamemodeTargetButton:setHeight(buttonHeight)
        local disabled = gamemode_object.disabled and true or false
        if mpconnect.enable_all_modes then
          disabled = false
        end
        self.gamemodeTargetButton:setDisabled(disabled)
        local text = gamemode_object.disabled and gamemode_object.disabled or "Start"
        self.gamemodeTargetButton:setText(text)
        self.gamemodeTargetButton:draw()

      end



      for button_index,button in pairs(self.gamemodes) do
        button:setX(bx)--x+paddingHorizontal+gamemode_object.image:getWidth())
        button:setY(by+(buttonHeight+paddingVertical)*(button_index-1))--target_y+(buttonHeight+paddingVertical)*(button_index-1))
        button:setWidth(buttonWidth)
        button:setHeight(buttonHeight)
        button:draw()
      end


    else

      local gamemode_object = self.mpgamemodes:getGamemodeById(self.gamemode)
      self.guide:setText(gamemode_object.guide_text)
      love.graphics.setFont(fonts.window_title)
      dropshadowf("Game Mode: "..gamemode_object.name,0,32,love.graphics.getWidth(),"center")
      love.graphics.setFont(fonts.default)

      local rows = {}
      for player_index,player_data in pairs(self._data) do
        local row = math.floor(player_index/5)%5
        rows[row] = rows[row] or {}
        table.insert(rows[row],player_data)
      end

      for row_index,row_data in pairs(rows) do
        for player_index,player_data in pairs(row_data) do

          local total_width = player_data:getWidth() * #row_data
          player_data:draw(
            (love.graphics.getWidth()-total_width)/2 + player_data:getWidth()*(player_index-1),
            love.graphics.getHeight()/2 + player_data:getHeight()*(row_index-1)
          )

        end
      end

      self.start:setX( (love.graphics.getWidth()-self.start:getWidth())/2 )
      self.start:setY( love.graphics.getHeight()-self.start:getHeight()-32 )
      self.start:draw()

      for button_index,button in pairs(self.buttons) do
        button:setX(32)
        button:setY(32+(button:getHeight()+4)*(button_index-1))
        button:setWidth(256+32)
        button:draw()
      end

      self.guide:draw(self.chat:getX(),32,self.chat:getWidth())

    end

  end

  self.openMenu:setX(32)
  self.openMenu:setY(love.graphics.getHeight()-self.start:getHeight()-32)
  self.openMenu:draw()

end

return mpconnect
