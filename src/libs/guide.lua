local guide = {}

guide.image = love.graphics.newImage("assets/hud/guide.png")

function guide.new(init)
  init = init or {}
  local self = {}

  self._padding = init.padding or 8
  self._text = init.text or ""
  self._font = init.font or fonts.default
  self._image = init.image or guide.image

  self.draw = guide.draw
  self.getHeight = guide.getHeight
  self.getWidth = guide.getWidth
  self.setText = guide.setText

  return self
end

function guide:draw(x,y,w)
  if self._text then
    local h = self._image:getHeight()+self._padding*2
    tooltipbg(x,y,w,h)
    love.graphics.setFont(self._font)
    local text_width = w-self._padding*3-self._image:getWidth()
    local width, wrapped_text = self._font:getWrap(self._text,text_width)
    local text_height = #wrapped_text*self._font:getHeight()
    local text_offset = (h-text_height)/2
    dropshadowf(self._text,
      x+self._padding,
      y+text_offset,
      text_width,
      "center")
    love.graphics.setColor(255,255,255)
    love.graphics.draw(self._image,
      x+w-self._image:getWidth()-self._padding,
      y+self._padding)
  end
end

function guide:getHeight()
  return self._image:getHeight()
end

function guide:getWidth()
  return self._image:getWidth()
end

function guide:setText(text)
  self._text = text
end

return guide
