local assetchooser = {}

local utf8 = require("utf8")

function assetchooser.new(init)
  init = init or {}
  local self = {}

  self._prompt = init.prompt or "Type a file and press return:"
  self._callback = init.callback or function() print"No callback defined." end

  self.draw = assetchooser.draw
  self.update = assetchooser.update
  self.textinput = assetchooser.textinput
  self.keypressed = assetchooser.keypressed

  self._asset = "assets/"

  return self

end

function assetchooser:draw()

  if not self._last_good_dir then
    self._last_good_dir = love.filesystem.getWorkingDirectory()
  end
  if love.filesystem.isDirectory(self._asset) then
    self._last_good_dir = self._asset
  end
  local dir_contents = love.filesystem.getDirectoryItems(self._last_good_dir)

  local font = love.graphics.getFont()
  local w = font:getWidth(self._asset)
  local h = font:getHeight()
  local x = (love.graphics.getWidth()-w)/2
  local y = (love.graphics.getHeight()-h)/8
  local old_color = {love.graphics.getColor()}

  love.graphics.setColor(255,255,255)
  love.graphics.print(self._prompt,x,y-font:getHeight()*2)


  love.graphics.setColor(0,0,0,127)
  local padding = 8
  love.graphics.rectangle("fill",x-padding,y-padding,w+padding*2,h+padding*2)
  if love.filesystem.isFile(self._asset) then
    love.graphics.setColor(0,255,0)
  else
    love.graphics.setColor(255,0,0)
  end
  love.graphics.rectangle("line",x-padding,y-padding,w+padding*2,h+padding*2)
  love.graphics.print(self._asset,x,y)
  local dir_contents_rend = table.concat(dir_contents,"\n")
  local dw = font:getWidth(dir_contents_rend)
  local dh = font:getHeight()*#dir_contents
  local dx = x
  local dy = y + font:getHeight()*2

  love.graphics.setColor(0,0,0,127)
  love.graphics.rectangle("fill",dx-padding,dy-padding,dw+padding*2,dh+padding*2)
  love.graphics.setColor(255,255,255)
  love.graphics.print(dir_contents_rend,dx,dy)

  love.graphics.setColor(old_color)
end

function assetchooser:textinput(t)
  self._asset = self._asset .. t
end

function assetchooser:keypressed(key)
  if key == "backspace" then
    local byteoffset = utf8.offset(self._asset, -1)
    if byteoffset then
      self._asset = string.sub(self._asset, 1, byteoffset - 1)
    end
  elseif key == "return" and love.filesystem.isFile(self._asset) then
    self._callback(self._asset)
  end
end

return assetchooser
