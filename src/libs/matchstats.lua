local matchstats = {}

matchstats.images = {
  bg = love.graphics.newImage("assets/hud/portrait_icons/bg.png"),
  ai = love.graphics.newImage("assets/hud/portrait_icons/ai.png"),
  user = love.graphics.newImage("assets/hud/portrait_icons/user.png"),
}

function matchstats.new(init)
  init = init or {}
  local self = {}

  self.update = matchstats.update
  self.draw = matchstats.draw
  self.getWidth = matchstats.getWidth
  self.getHeight = matchstats.getHeight

  self._padding = 16
  self._rowSize = 32

  return self
end

function matchstats:update(dt)
end

function matchstats:draw(players,user,current_time)

  local w,h = self:getWidth(),self:getHeight(players)
  local x = (love.graphics.getWidth()-w)/2
  local y = (love.graphics.getHeight()-h)/2
  tooltipbg(x,y,w,h)

  dropshadowf(libs.i18n('client.match_time')..seconds_to_clock(current_time),
    x+self._padding,y+self._padding,w-self._padding*2,"center")

  local vtextoffset = (self._rowSize-love.graphics.getFont():getHeight())/2

  for player_index,player in pairs(players) do

    local user_data = libs.net.getUser(player_index-1)
    local sx,sy = x+self._padding,y+self._padding+(player_index+1)*self._rowSize

    -- align left
    local cx = 0
    love.graphics.setColor({user_data.color[1],user_data.color[2],user_data.color[3],127})
    love.graphics.draw(
      matchstats.images.bg,
      sx,sy
    )
    love.graphics.setColor(user_data.selected_color)
    love.graphics.draw(
      player.ai and matchstats.images.ai or matchstats.images.user,
      sx,sy
    )
    cx = cx + 32 + self._padding
    if user.id == player.id then
      love.graphics.setColor(0,255,0)
    else
      love.graphics.setColor(255,255,255)
    end

    local user_name
    if player.ai then
      user_name = "AI ["..libs.net.aiDifficulty[player.diff].text.."]"
    else
      user_name = player.user_name
    end
    dropshadow(user_name,sx+cx,sy+vtextoffset)
    love.graphics.setColor(255,255,255)

    -- align right
    if libs.net.isOnSameTeam(players,user.id,player_index-1) then
      love.graphics.setColor(0,255,0)
    else
      love.graphics.setColor(255,0,0)
    end
    dropshadowf("Team "..player.team,sx,sy+vtextoffset,w-self._padding*2,"right")
    love.graphics.setColor(255,255,255)


  end

  if debug_mode then
    debugrect(x,y,w,h)
  end

end

function matchstats:getWidth()
  return 256
end

function matchstats:getHeight(players)
  return (#players+2)*self._rowSize + self._padding * 2
end

return matchstats
