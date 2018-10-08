local social = {}

function social.new(init)
  init = init or {}
  local self = {}

  self.update = social.update
  self.draw = social.draw

  self._data = {}
  self._dir = "assets/social/"
  for _,filename in pairs(love.filesystem.getDirectoryItems(self._dir)) do
    local data = require(self._dir..filename)
    data.image = love.graphics.newImage(self._dir..filename.."/icon.png")
    table.insert(self._data,data)
  end

  self._panel = libs.matrixpanel.new{
    iconSize=64,
    padding=4,
    width=64*#self._data+4*4,
    drawbg=false,
    icon_bg=love.graphics.newImage("assets/hud/icon_bg_large.png")
  }

  for _,data in pairs(self._data) do
    self._panel:addAction(
      data.image,
      function()
        love.system.openURL(data.uri)
      end,
      nil,
      data.desc
    )
  end

  return self
end

function social:update(dt)
  if love.mouse.isDown(1) then
    if self._wait_for_release ~= true  and self._panel:mouseInside() then
      self._wait_for_release = true
      self._panel:runHoverAction()
    end
  else
    self._wait_for_release = false
  end
  self._panel:update(dt)
end

function social:draw()
  self._panel:draw()
end

return social
