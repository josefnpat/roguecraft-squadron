local mptutorial = {}

mptutorial.icons = {
  prev=love.graphics.newImage("assets/hud/arrow_prev.png"),
  next=love.graphics.newImage("assets/hud/arrow_next.png"),
}

local data = {}
for _,type in pairs(love.filesystem.getDirectoryItems("assets/tutorial/")) do
  local object = {}
  local dir = "assets/tutorial/"..type
  local po_file = dir.."/en.po"
  local po_raw = love.filesystem.read(po_file)

  object.loc = {}
  for _,entry in pairs(libs.gettext.decode(po_raw)) do
    object.loc[entry.id] = entry.str
  end
  local image_file = dir.."/image.png"
  object.image = love.graphics.newImage(image_file)

  table.insert(data,object)
end

function mptutorial.new(init)
  init = init or {}
  local self = libs.mpwindow.new()

  self.changeCurrent = mptutorial.changeCurrent
  self.setActive = mptutorial.setActive
  self.getMaxTextHeight = mptutorial.getMaxTextHeight
  self.getText = mptutorial.getText
  self.getTextWidth = mptutorial.getTextWidth
  self.getTextHeight = mptutorial.getTextHeight
  self.getWidth = mptutorial.getWidth -- override
  self.getHeight = mptutorial.getHeight -- override
  self.draw = mptutorial.draw
  self.update = mptutorial.update

  self._current = 1
  self._active = false
  self._text_font = fonts.default
  self._calc_text_height = self:getMaxTextHeight()

  self.prev = libs.button.new{
    height=self._button_height,
    width = 32,
    onClick = function()
      self:changeCurrent(-1)
    end,
    icon=mptutorial.icons.prev,
  }

  self.next = libs.button.new{
    height=self._button_height,
    width = 32,
    onClick = function()
      self:changeCurrent(1)
    end,
    icon=mptutorial.icons.next,
  }

  self:setWindowTitle("Tutorial")

  self:changeCurrent(0)

  return self
end

function mptutorial:changeCurrent(val)
  self._current = self._current + val
  self.prev:setDisabled(self._current == 1)
  self.next:setDisabled(self._current == #data)
end

function mptutorial:setActive(val)
  if val then
    print("setting tutorial to false.")
    settings:write("tutorial",false)
  end
  self._active = val
end

function mptutorial:getMaxTextHeight()
  local cmax = 0
  for cdata_index,cdata in pairs(data) do
    cmax = math.max(cmax,self:getTextHeight(cdata_index))
  end
  return cmax
end

function mptutorial:getText(index)
  index = index or self._current
  local cdata = data[index]
  return index..". "..cdata.loc.desc
end

function mptutorial:getTextWidth(index)
  index = index or self._current
  return self:getWidth()-self._padding*2
end

function mptutorial:getTextHeight(index)
  index = index or self._current
  local text_width = self:getTextWidth(index)
  local cdata = data[index]
  local desc = self:getText(index)
  local _,text_wrappings = self._text_font:getWrap( desc, text_width )
  return self._text_font:getHeight()*#text_wrappings
end

function mptutorial:getWidth()
  local cdata = data[self._current]
  return cdata.image:getWidth()+self._padding*2
end

function mptutorial:getHeight()
  return
    fonts.window_title:getHeight() +
    data[self._current].image:getHeight() +
    self._calc_text_height +
    self._closeButton:getHeight() +
    self._padding*5
end

function mptutorial:draw()

  if self:isActive() then

    local window,content = self:windowdraw()

    local cdata = data[self._current]
    local padding = self._padding

    local coff = content.y

    love.graphics.draw(cdata.image,content.x,coff)

    coff = coff + cdata.image:getHeight() + padding
    love.graphics.printf(
      self:getText(),
      content.x,
      coff,
      self:getTextWidth(),
      "left")

    coff = coff + self._calc_text_height + padding

    self.prev:setX(content.x)
    self.prev:setY(coff)
    self.prev:draw()

    self.next:setX(window.x+self.next:getWidth()+padding*2)
    self.next:setY(coff)
    self.next:draw()

  end

end

function mptutorial:update(dt)
  if self:isActive() then
    self:windowupdate(dt)
    self.prev:update(dt)
    self.next:update(dt)
  end
end

return mptutorial
