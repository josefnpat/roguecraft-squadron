local tutorial = {}

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

function tutorial.new(init)
  init = init or {}
  local self = {}

  self.changeCurrent = tutorial.changeCurrent
  self.show = tutorial.show
  self.hide = tutorial.hide
  self.toggle = tutorial.toggle
  self.active = tutorial.active
  self.update = tutorial.update
  self.draw = tutorial.draw
  self._current = 1
  self._show = false

  self._buttonHeight = 32

  self.prev = libs.button.new{
    height=self._buttonHeight,
    width = 96,
    text = "Previous",
    onClick = function()
      self:changeCurrent(-1)
    end,
  }

  self.next = libs.button.new{
    height=self._buttonHeight,
    width = 96,
    text = "Next",
    onClick = function()
      self:changeCurrent(1)
    end,
  }

  self.close = libs.button.new{
    height=self._buttonHeight,
    width = 64,
    text = "Close",
    onClick = function()
      self:hide()
    end,
  }

  self:changeCurrent(0)

  return self
end

function tutorial:changeCurrent(val)
  self._current = self._current + val
  self.prev:setDisabled(self._current == 1)
  self.next:setDisabled(self._current == #data)
end

function tutorial:show()
  settings:write("tutorial",false)
  self._show = true
end

function tutorial:hide()
  self._show = false
end

function tutorial:toggle()
  self._show = not self._show
end

function tutorial:active()
  return self._show
end

function tutorial:update(dt)
  if self._show then
    self.prev:update(dt)
    self.next:update(dt)
    self.close:update(dt)
  end
end

function tutorial:draw()

  if self._show ~= true then return end

  love.graphics.setColor(0,0,0,191)
  love.graphics.rectangle("fill",0,0,
    love.graphics:getWidth(),love.graphics:getHeight())
  love.graphics.setColor(255,255,255)

  local cdata = data[self._current]
  local padding = 16

  local w = cdata.image:getWidth()+padding*2
  local font = love.graphics.getFont()
  local text_width = w-padding*2
  local desc = self._current..". "..cdata.loc.desc
  local _,text_wrappings = font:getWrap( desc, text_width )
  local text_height = font:getHeight()*#text_wrappings
  local h = cdata.image:getHeight()+padding*4+text_height+self._buttonHeight
  local x = (love.graphics.getWidth()-w)/2
  local y = (love.graphics.getHeight()-h)/2

  tooltipbg(x,y,w,h)

  local coff = y + padding
  love.graphics.setColor(255,255,255)
  love.graphics.draw(cdata.image,x+padding,coff)

  coff = coff + cdata.image:getHeight() + padding
  love.graphics.printf(desc,x+padding,coff,text_width,"left")

  coff = coff + text_height + padding

  self.prev:setX(x+padding)
  self.prev:setY(coff)
  self.prev:draw()

  self.next:setX(x+self.next:getWidth()+padding*2)
  self.next:setY(coff)
  self.next:draw()

  self.close:setX(x+(w-self.close:getWidth())-padding)
  self.close:setY(coff)
  self.close:draw()

end

return tutorial
