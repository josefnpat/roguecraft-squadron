local stringchooser = {}

local utf8 = require("utf8")

function stringchooser.new(init)
  init = init or {}
  local self = {}

  self._prompt = init.prompt or "Type a string and press return:"
  self._callback = init.callback or function() print"No callback defined." end

  self.draw = stringchooser.draw
  self.update = stringchooser.update
  self.textinput = stringchooser.textinput
  self.keypressed = stringchooser.keypressed

  self._asset = init.string or ""

  return self

end

function stringchooser:draw()

  love.graphics.setColor(0,0,0,127)
  love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())

  local font = love.graphics.getFont()
  local wa = font:getWidth(self._asset)
  local wp = font:getWidth(self._prompt)
  local w = math.max(wa,wp)
  local h = font:getHeight()
  local x = (love.graphics.getWidth()-w)/2
  local y = (love.graphics.getHeight()-h)/2
  local old_color = {love.graphics.getColor()}

  local padding = 8

  tooltipbg(
    x-padding*2,
    y-font:getHeight()*2,
    w+padding*2*2,
    h+font:getHeight()*2+padding*2
  )

  love.graphics.setColor(255,255,255)
  love.graphics.print(self._prompt,x,y-font:getHeight()*2+padding)

  love.graphics.setColor(0,0,0,127)

  love.graphics.rectangle("fill",x-padding,y-padding,w+padding*2,h+padding*2)
  if string.len(self._asset) > 0 then
    love.graphics.setColor(0,255,0)
  else
    love.graphics.setColor(255,0,0)
  end
  love.graphics.rectangle("line",x-padding,y-padding,w+padding*2,h+padding*2)
  love.graphics.print(self._asset,x,y)

  love.graphics.setColor(old_color)
end

function stringchooser:textinput(t)
  self._asset = self._asset .. t
end

function stringchooser:keypressed(key)
  if key == "backspace" then
    local byteoffset = utf8.offset(self._asset, -1)
    if byteoffset then
      self._asset = string.sub(self._asset, 1, byteoffset - 1)
    end
  elseif key == "return" then
    self._callback(self._asset)
  end
end

return stringchooser
