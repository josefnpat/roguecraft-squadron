local mpconnect = {}

function mpconnect.new(init)
  init = init or {}
  local self = {}

  self.lovernet = init.lovernet
  self.ai_count = init.ai_count or 0

  self.update = mpconnect.update
  self.draw = mpconnect.draw
  self.setAiCount = mpconnect.setAiCount

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

  return self
end

function mpconnect:update(dt)
  self.start:update(dt)
  for _,button in pairs(self.buttons) do
    button:update(dt)
  end
end

function mpconnect:setAiCount(count)
  self.ai_count = count
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

  if players then
    for player_index,player in pairs(players) do
      local type = player.ai == nil and "user" or "ai"
      local user_name = player.ai == nil and player.user_name or "AI"
      local lol = libs.mpconnectplayer.new{
        type=type,
        user_name=user_name,
      }
      local total_width = lol:getWidth() * #players
      lol:draw(
        (love.graphics.getWidth()-total_width)/2 + lol:getWidth()*(player_index-1),
        love.graphics.getHeight()/2 - lol:getHeight()
      )
    end
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
