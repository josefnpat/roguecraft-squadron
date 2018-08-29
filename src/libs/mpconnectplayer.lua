local mpconnectplayer = {}

mpconnectplayer.img = {
  user = love.graphics.newImage("assets/hud/portraits/user.png"),
  ai = love.graphics.newImage("assets/hud/portraits/ai.png"),
}

function mpconnectplayer.new(init)
  init = init or {}
  local self = {}

  self.draw = mpconnectplayer.draw
  self.getWidth = mpconnectplayer.getWidth
  self.getHeight = mpconnectplayer.getHeight
  self._type = init.type or "user"
  self._user_name = init.user_name or "Loading ..."
  self._inner_padding = 8
  self._outer_padding = 4

  return self
end

function mpconnectplayer:draw(x,y)
  --love.graphics.rectangle("line",x,y,self:getWidth(),self:getHeight())
  tooltipbg(x+self._outer_padding,y+self._outer_padding,
    self:getWidth()-self._outer_padding*2,self:getHeight()-self._outer_padding*2)
  love.graphics.setColor(255,255,255)

  local image = mpconnectplayer.img[self._type]
  local target_width = self:getWidth()-self._inner_padding*2-self._outer_padding*2
  local scale = target_width/image:getWidth()
  love.graphics.draw(image,
    x+self._inner_padding+self._outer_padding,
    y+self._inner_padding+self._outer_padding,
    0,scale,scale)
  love.graphics.printf(self._user_name,x,y+image:getHeight()*scale+32,self:getWidth(),"center")

end

function mpconnectplayer:getWidth()
  return 128+self._inner_padding*2
end

function mpconnectplayer:getHeight()
  return 128+64+self._inner_padding*2
end

return mpconnectplayer
