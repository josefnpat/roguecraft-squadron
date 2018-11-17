local mpconnect = {}

function mpconnect.new(init)
  init = init or {}
  local self = {}

  self.lovernet = init.lovernet
  self.chat = init.chat
  self.ai_count = init.ai_count or 0
  self.creative = false
  self.everyShipUnlocked = false
  self.preset = init.preset or #libs.mppresets.getPresets()
  self.transmitRate = init.transmitRate or 1
  self.points = init.points or 1
  self.mpgamemodes = init.mpgamemodes
  self.target_gamemode = self.mpgamemodes:getGamemodes()[1].id

  self.generateButtons = mpconnect.generateButtons
  self.updateData = mpconnect.updateData
  self.update = mpconnect.update
  self.draw = mpconnect.draw
  self.setAiCount = mpconnect.setAiCount
  self.setCreative = mpconnect.setCreative
  self.setEveryShipUnlocked = mpconnect.setEveryShipUnlocked
  self.setPreset = mpconnect.setPreset
  self.setPoints = mpconnect.setPoints
  self.setGamemode = mpconnect.setGamemode
  self.setTransmitRate = mpconnect.setTransmitRate
  self.setUser = mpconnect.setUser
  self.validateVersion = mpconnect.validateVersion

  self._players = {}
  self._data = {}

  self.start = libs.button.new{
    text=function()
      local player = libs.net.getPlayerById(self._players,self._user_id)
      return player.ready and "Ready" or "Not Ready"
    end,
    onClick=function()
      local player = libs.net.getPlayerById(self._players,self._user_id)
      self.lovernet:pushData(libs.net.op.set_players,{
        d={ready=not player.ready},
        p=self._user_id,
        t="u"})
    end,
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

function mpconnect:generateButtons()

  self.buttons = {}

  self.presetButton = libs.button.new{
    disabled=#libs.mppresets.getPresets()<=1,
    text="Preset",
    onClick=function()
      self.lovernet:pushData(libs.net.op.set_config,{d={preset=self.preset+1}})
    end,
  }
  table.insert(self.buttons,self.presetButton)

  self.transmitRatesButton = libs.button.new{
    text="Network",
    onClick=function()
      self.lovernet:pushData(libs.net.op.set_config,{d={transmitRate=self.transmitRate+1}})
    end,
  }
  table.insert(self.buttons,self.transmitRatesButton)

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

    table.insert(self.buttons,libs.button.new{
      text="Add AI",
      onClick=function()
        self.lovernet:pushData(libs.net.op.set_config,{d={ai=self.ai_count+1}})
      end,
    })

    table.insert(self.buttons,libs.button.new{
      text="Remove AI",
      onClick=function()
        self.lovernet:pushData(libs.net.op.set_config,{d={ai=self.ai_count-1}})
      end,
    })

    table.insert(self.buttons,libs.button.new{
      disabled=not isRelease(),
      text=function() return self.creative and "Build Mode [Creative]" or "Build Mode [Normal]" end,
      onClick=function()
        self.lovernet:pushData(libs.net.op.set_config,{d={creative=not self.creative}})
      end,
    })

    table.insert(self.buttons,libs.button.new{
      disabled=not isRelease(),
      text=function() return self.everyShipUnlocked and "Research [All Unlocked]" or "Research [Normal]" end,
      onClick=function()
        self.lovernet:pushData(libs.net.op.set_config,{d={everyShipUnlocked=not self.everyShipUnlocked}})
      end,
    })

    self.pointsButton = libs.button.new{
      disabled=not isRelease(),
      text="Points",
      onClick=function()
        self.lovernet:pushData(libs.net.op.set_config,{d={points=self.points+1}})
      end,
    }
    table.insert(self.buttons,self.pointsButton)

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
        diff=player.diff,
        lovernet = self.lovernet,
      }
      table.insert(self._data,player_data)
    end
  end
end

function mpconnect:update(dt)
  if self.gamemode == nil then
    for _,button in pairs(self.gamemodes) do
      button:update(dt)
    end
    self.gamemodeTargetButton:update(dt)
  else

    local gamemode_object = self.mpgamemodes:getGamemodeById(self.gamemode)
    for _,player_data in pairs(self._data) do
      player_data:setConfigurable(gamemode_object.configurable)
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

  libs.stars:draw()
  libs.stars:drawPlanet()

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

    libs.loading.draw("Checking client and server version config ...")

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

      local gamemode_object = self.mpgamemodes:getGamemodeById(self.target_gamemode)
      local x = (love.graphics.getWidth() - gamemode_object.image:getWidth() - buttonWidth - paddingHorizontal)/2

      local name_height = fonts.title:getHeight()
      local image_height = gamemode_object.image:getHeight()
      local desc_height = fonts.default:getHeight() -- w/e i'm lazy
      local target_y = (love.graphics.getHeight() - name_height - image_height - desc_height)/2
      love.graphics.draw(gamemode_object.image,x,target_y)
      love.graphics.setFont(fonts.title)
      dropshadow(gamemode_object.name,x,target_y+image_height)
      love.graphics.setFont(fonts.default)
      dropshadowf(gamemode_object.desc:gsub("\n"," "),x,target_y+image_height+name_height,gamemode_object.image:getWidth())

      for button_index,button in pairs(self.gamemodes) do
        button:setX(x+paddingHorizontal+gamemode_object.image:getWidth())
        button:setY(target_y+(buttonHeight+paddingVertical)*(button_index-1))
        button:setWidth(buttonWidth)
        button:setHeight(buttonHeight)
        button:draw()
      end

      local targetVerticalOffset = (name_height - buttonHeight)/2

      self.gamemodeTargetButton:setX(x+gamemode_object.image:getWidth()-buttonWidth)
      self.gamemodeTargetButton:setY(target_y+gamemode_object.image:getHeight()+targetVerticalOffset+paddingVertical)
      self.gamemodeTargetButton:setWidth(buttonWidth)
      self.gamemodeTargetButton:setHeight(buttonHeight)
      self.gamemodeTargetButton:setDisabled(gamemode_object.disabled)
      self.gamemodeTargetButton:setText(gamemode_object.disabled and "Coming Soon!" or "Start")
      self.gamemodeTargetButton:draw()

    else

      local gamemode_object = self.mpgamemodes:getGamemodeById(self.gamemode)
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

    end

  end

end

return mpconnect
