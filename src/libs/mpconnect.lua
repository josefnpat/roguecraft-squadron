local mpconnect = {}

function mpconnect.new(init)
  init = init or {}
  local self = {}

  self.lovernet = init.lovernet
  self.ai_count = init.ai_count or 0
  self.preset = init.preset or #libs.mppresets.getPresets()

  self.updateData = mpconnect.updateData
  self.update = mpconnect.update
  self.draw = mpconnect.draw
  self.setAiCount = mpconnect.setAiCount
  self.setPreset = mpconnect.setPreset

  self._players = {}
  self._data = {}

  self.start = libs.button.new{
    text="Start Battle",
    onClick=function()
      self.lovernet:pushData(libs.net.op.set_config,{d={game_start=true}})
    end,
  }

  self.buttons = {}

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

  self.presetButton = libs.button.new{
    text="Preset",
    onClick=function()
      self.lovernet:pushData(libs.net.op.set_config,{d={preset=self.preset+1}})
    end,
  }
  table.insert(self.buttons,self.presetButton)

  return self
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
  self.start:update(dt)
  for _,button in pairs(self.buttons) do
    button:update(dt)
  end
  for _,player_data in pairs(self._data) do
    player_data:update(dt)
  end
end

function mpconnect:setAiCount(count)
  self.ai_count = count
end

function mpconnect:setPreset(preset_value)
  self.preset = preset_value
  local preset = libs.mppresets.getPresets()[preset_value]
  self.presetButton:setText(preset.name)
end

function mpconnect:draw(config,players,user_count)

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

  for player_index,player_data in pairs(self._data) do
    local total_width = player_data:getWidth() * #self._data
    player_data:draw(
      (love.graphics.getWidth()-total_width)/2 + player_data:getWidth()*(player_index-1),
      love.graphics.getHeight()/2 - player_data:getHeight()
    )
  end

  self.start:setX( (love.graphics.getWidth()-self.start:getWidth())/2 )
  self.start:setY( love.graphics.getHeight()/2 + self.start:getHeight() )
  self.start:draw()

  for button_index,button in pairs(self.buttons) do
    button:setX(32)
    button:setY(32+(button:getHeight()+16)*(button_index-1))
    button:setWidth(128)
    button:draw()
  end
end

return mpconnect
