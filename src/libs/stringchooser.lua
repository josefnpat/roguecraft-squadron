local stringchooser = {}

local utf8 = require("utf8")

function stringchooser.new(init)
  init = init or {}
  local self = {}

  self._prompt = init.prompt or "Type a string and press return:"
  self._callback = init.callback or function() print"No callback defined." end
  self._cancelCallback = init.cancelCallback

  self.draw = stringchooser.draw
  self.update = stringchooser.update
  self.textinput = stringchooser.textinput
  self.keypressed = stringchooser.keypressed

  self._asset = init.string or ""
  self._validate = init.validate or
    function(asset) return string.len(asset) > 0 end
  self._mask = init.mask or
    function(asset) return asset end

  self._okButton = libs.button.new{
    text = "Accept",
    onClick = function()
      self._callback(self._asset)
    end,
    disabled=true,
  }
  if self._cancelCallback then
    self._cancelButton = libs.button.new{
      text = "Cancel",
      onClick = function()
        self._cancelCallback()
      end,
    }
  end

  return self

end

function stringchooser:draw()

  local old_color = {love.graphics.getColor()}
  local old_font = love.graphics.getFont()

  love.graphics.setColor(0,0,0,127)
  love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),
    love.graphics.getHeight())

  local font = fonts.menu
  love.graphics.setFont(font)
  local wa = font:getWidth(self._asset)
  local wp = font:getWidth(self._prompt)
  local w = math.max(wa,wp,192)
  local h = font:getHeight()
  local x = (love.graphics.getWidth()-w)/2
  local y = (love.graphics.getHeight()-h)/2

  local padding = 8

  local button_offset_y = h+padding*2
  local button_height = 40
  local button_width = 96

  self._okButton:setWidth(button_width)
  self._okButton:setHeight(button_height)
  self._okButton:setX(x+w-self._okButton:getWidth()+padding)
  self._okButton:setY(y+button_offset_y)

  self._okButton:setDisabled(not self._validate(self._asset))

  if self._cancelButton then
    self._cancelButton:setWidth(button_width)
    self._cancelButton:setHeight(button_height)
    self._cancelButton:setX(x-padding)
    self._cancelButton:setY(y+button_offset_y)
  end

  tooltipbg(
    x-padding*2,
    y-font:getHeight()*2,
    w+padding*2*2,
    h+font:getHeight()*2+padding*3+button_height
  )

  love.graphics.setColor(255,255,255)
  love.graphics.print(self._prompt,x,y-font:getHeight()*2+padding)

  love.graphics.setColor(0,0,0,127)

  love.graphics.rectangle("fill",x-padding,y-padding,w+padding*2,h+padding*2)
  if self._validate(self._asset) then
    love.graphics.setColor(0,255,0)
  else
    love.graphics.setColor(255,0,0)
  end
  love.graphics.rectangle("line",x-padding,y-padding,w+padding*2,h+padding*2)
  love.graphics.print(self._mask(self._asset),x,y)

  self._okButton:draw()
  if self._cancelButton then
    self._cancelButton:draw()
  end

  love.graphics.setColor(old_color)
  love.graphics.setFont(old_font)
end

function stringchooser:update(dt)
  self._okButton:update(dt)
  if self._cancelButton then
    self._cancelButton:update(dt)
  end
  if love.keyboard.isDown("lctrl") and love.keyboard.isDown("v") then
    self._asset = love.system.getClipboardText()
  end
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
  elseif key == "return" or key == "kpenter" then
    if self._validate(self._asset) then
      self._callback(self._asset)
    end
  end
end

return stringchooser
