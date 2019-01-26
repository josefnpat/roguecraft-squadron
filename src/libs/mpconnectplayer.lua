local mpconnectplayer = {}

mpconnectplayer.img = {
  user = love.graphics.newImage("assets/hud/portraits/user.png"),
  ai = love.graphics.newImage("assets/hud/portraits/ai.png"),
}

mpconnectplayer.icons = {
  check = love.graphics.newImage("assets/hud/check.png"),
  check_empty = love.graphics.newImage("assets/hud/check_empty.png"),
}

function mpconnectplayer.new(init)
  init = init or {}
  local self = {}

  self.lovernet = init.lovernet

  self.draw = mpconnectplayer.draw
  self.update = mpconnectplayer.update
  self.getWidth = mpconnectplayer.getWidth
  self.getHeight = mpconnectplayer.getHeight
  self.setConfigurable = mpconnectplayer.setConfigurable
  self._type = init.type or "user"
  self._user_name = init.user_name or "Loading ..."
  self._user_id = init.user_id or 0
  self._ready = init.ready
  self._player_index = init.player_index or 0
  self._team = init.team or 1
  self._diff = init.diff or 1
  self._configurable = init.configurable or false
  self._inner_padding = 8
  self._outer_padding = 4

  self._changeTeam = libs.button.new{
    height=24,
    text=function()
      return self._team
    end,
    onClick=function()
      self.lovernet:pushData(libs.net.op.set_players,{
        d={team=self._team+1},
        p=self._user_id,
        t=self._type=="user" and "u" or "ai"})
    end,
    tooltip=function(data)
      return "This player is on team "..self._team
    end,
  }

  if self._type ~= "user" then
    -- todo: add tooltips for buttons
    self._changeDiff = libs.stepper.new{
      height=24,
      text=function()
        local diff = libs.net.aiDifficulty[self._diff]
        return diff.roman_numeral--.." ["..diff.apm().."]"
      end,
      onClick=function(dir)
        self.lovernet:pushData(libs.net.op.set_players,{
          d={diff=self._diff+dir},
          p=self._user_id,
          t="ai"})
      end,
      font=fonts.submenu,
      tooltip=function(data)
        local diff = libs.net.aiDifficulty[self._diff]
        return "This AI is set to difficulty ".. diff.full_text .. " (" .. diff.roman_numeral .. ")"
      end,
    }
  end

  return self
end

function mpconnectplayer:draw(x,y)
  local user = libs.net.getUser(self._player_index-1)
  --love.graphics.rectangle("line",x,y,self:getWidth(),self:getHeight())
  tooltipbg(x+self._outer_padding,y+self._outer_padding,
    self:getWidth()-self._outer_padding*2,self:getHeight()-self._outer_padding*2,
    user.color,user.selected_color)
  love.graphics.setColor(255,255,255)

  local image = mpconnectplayer.img[self._type]
  local target_width = self:getWidth()-self._inner_padding*2-self._outer_padding*2
  local scale = target_width/image:getWidth()
  local target_height = image:getHeight()*scale
  local target_x = x+self._inner_padding+self._outer_padding
  local target_y = y+self._inner_padding+self._outer_padding
  love.graphics.draw(image,
    target_x,
    target_y,
    0,scale,scale)

  local text = self._user_name
  dropshadowf(text,x,y+image:getHeight()*scale+32,self:getWidth(),"center")
  if self._type=="user" then
    local ready_image = self._ready and mpconnectplayer.icons.check or mpconnectplayer.icons.check_empty
    love.graphics.draw(ready_image,
      x+(self:getWidth()-ready_image:getWidth())/2,
      y+image:getHeight()*scale+32+love.graphics.getFont():getHeight())
  end

  if self._configurable then
    self._changeTeam:setX(target_x)
    self._changeTeam:setY(target_y + target_height - self._changeTeam:getHeight())
    self._changeTeam:setWidth(self._changeTeam:getHeight())
    self._changeTeam:draw()
  end

  if self._changeDiff then
    self._changeDiff:setX(target_x)
    self._changeDiff:setY(128+target_y + target_height - self._changeDiff:getHeight())
    self._changeDiff:setWidth(target_width)
    self._changeDiff:draw()
  end

end

function mpconnectplayer:update(dt)
  if self._configurable then
    self._changeTeam:update(dt)
  end
  if self._changeDiff then
    self._changeDiff:update(dt)
  end
end

function mpconnectplayer:getWidth()
  return 128+self._inner_padding*2
end

function mpconnectplayer:getHeight()
  return 192+64+self._inner_padding*2
end

function mpconnectplayer:setConfigurable(val)
  self._configurable = val
end

return mpconnectplayer
