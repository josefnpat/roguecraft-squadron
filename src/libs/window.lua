local window = {}

window.s = love.graphics.newImage("assets/window.png")
window.icon_bg = love.graphics.newImage("assets/icon_bg.png")

window.topleft =     love.graphics.newQuad(0,0,32,32,96,96)
window.top =         love.graphics.newQuad(32,0,32,32,96,96)
window.topright =    love.graphics.newQuad(64,0,32,32,96,96)
window.right =       love.graphics.newQuad(64,32,32,32,96,96)
window.bottomright = love.graphics.newQuad(64,64,32,32,96,96)
window.bottom =      love.graphics.newQuad(32,64,32,32,96,96)
window.bottomleft =  love.graphics.newQuad(0,64,32,32,96,96)
window.left =        love.graphics.newQuad(0,32,32,32,96,96)
window.center =      love.graphics.newQuad(32,32,32,32,96,96)

function window.new(init)
  init = init or {}
  local self = {}

  self.dt = 0

  self.title = init.title or nil
  self.title_font = (fonts and fonts.window_title) or init.title_font or love.graphics.getFont()
  self.text = init.text or "N/A"
  self.text_font = init.text_font or love.graphics.getFont()
  self.ptext = ""
  self.color = init.color or {0,255,0}

  self.guides = init.guides or {}
  self.image = init.image or nil
  self.buttons = init.buttons or {}

  self.draw = window.draw
  self.update = window.update
  self.inArea = window.inArea
  self.addButton = window.addButton
  self.addGuide = window.addGuide

  self.recalculateHeight = window.recalculateHeight

  self._buttonAreas = window._buttonAreas
  self._checkArea = window._checkArea
  self._titleHeight = window._titleHeight
  self._textHeight = window._textHeight
  self._guideHeight = window._guideHeight
  self._imageHeight = window._imageHeight
  self._imageScale = window._imageScale
  self._buttonHeight = window._buttonHeight
  self._recalculateHeight = window._recalculateHeight
  self._wait_mouse_release = true

  self._spad = 8

  self.w = init.w or 320
  self.h = init.h or self:_recalculateHeight()
  self.x = init.x or love.graphics.getWidth()-32-self.w
  self.y = init.y or love.graphics.getHeight()-32-self.h

  return self
end

function window:draw()

  local old_color = {love.graphics.getColor()}
  local old_font = love.graphics.getFont()

  love.graphics.setColor(self.color)

  love.graphics.setScissor(self.x+32,self.y+32,self.w-64,self.h-64)
  for i = 1,self.w/32-1 do
    for j = 1,self.h/32-1 do
      love.graphics.draw(window.s,window.center,self.x+i*32,self.y+j*32)
    end
  end
  love.graphics.setScissor()

  love.graphics.draw(window.s,window.topleft,self.x,self.y)
  love.graphics.setScissor(self.x+32,self.y,self.w-64,32)
  for i = 1,self.w/32-1 do
    love.graphics.draw(window.s,window.top,self.x+i*32,self.y)
  end
  love.graphics.setScissor()
  love.graphics.draw(window.s,window.topright,self.x+self.w-32,self.y)
  love.graphics.setScissor(self.x+self.w-32,self.y+32,32,self.h-64)
  for i = 1,self.h/32-1 do
    love.graphics.draw(window.s,window.right,self.x+self.w-32,self.y+i*32)
  end
  love.graphics.setScissor()
  love.graphics.draw(window.s,window.bottomleft,self.x,self.y+self.h-32)
  love.graphics.setScissor(self.x+32,self.y+self.h-32,self.w-64,32)
  for i = 1,self.w/32-1 do
    love.graphics.draw(window.s,window.bottom,self.x+i*32,self.y+self.h-32)
  end
  love.graphics.setScissor()
  love.graphics.draw(window.s,window.bottomright,self.x+self.w-32,self.y+self.h-32)
  love.graphics.setScissor(self.x,self.y+32,32,self.h-64)
  for i = 1,self.h/32-1 do
    love.graphics.draw(window.s,window.left,self.x,self.y+i*32)
  end
  love.graphics.setScissor()

  love.graphics.setColor(old_color)

  local coffset = 32
  local tfont = love.graphics.getFont()

  if self.title then
    love.graphics.setFont(self.title_font)
    --love.graphics.rectangle("line",self.x+32,self.y+coffset,self.w-64,self:_titleHeight())
    dropshadowf(self.title,
      self.x+32,self.y+coffset,
      self.w-64,"center")
    coffset = coffset + self:_titleHeight()
  end

  love.graphics.setFont(self.text_font)

  if self.text then
    --love.graphics.rectangle("line",self.x+32,self.y+coffset,self.w-64,self:_textHeight())
    dropshadowf(self.ptext,
      self.x+32,self.y+coffset,
      self.w-64,"left")
    coffset = coffset + self:_textHeight()
  end

  if #self.guides > 0 then
    --love.graphics.rectangle("line",self.x+32,self.y+coffset,self.w-64,self:_guideHeight())
    for iguide,guide in pairs(self.guides) do
      love.graphics.draw(window.icon_bg,self.x+32,self.y+coffset+32*(iguide-1))
      love.graphics.draw(guide.icon,self.x+32,self.y+coffset+32*(iguide-1))
      dropshadow(guide.text,
        self.x+64+8,
        self.y+coffset+32*(iguide-1)+(32-tfont:getHeight())/2
      )
    end
    coffset = coffset + self:_guideHeight()
  end

  if self.image then
    --love.graphics.rectangle("line",self.x+32,self.y+coffset,self.w-64,self:_imageHeight())
    local s = self:_imageScale()
    love.graphics.draw(self.image,self.x+32,self.y+coffset,0,s,s)
    coffset = coffset + self:_imageHeight()
  end

  if #self.buttons > 0 then
    --love.graphics.rectangle("line",self.x+32,self.y+coffset,self.w-64,self._buttonHeight())
    for _,obj in pairs(self:_buttonAreas()) do
      love.graphics.setColor(obj.button.hover and {255,255,255,127} or {127,127,127,127})
      love.graphics.rectangle("fill",obj.area.x,obj.area.y+coffset,obj.area.w,obj.area.h)
      love.graphics.setColor(255,255,255)
      dropshadow(obj.button.text,obj.area.x+8,obj.area.y+coffset+(obj.area.h-tfont:getHeight())/2)
    end
    coffset = coffset + self:_buttonHeight()
  end

  love.graphics.setFont(old_font)

end

function window:update(dt)
  self.dt = self.dt + dt

  self.ptext = string.sub(self.text,1,math.min(self.dt,1)*string.len(self.text))

  if not love.mouse.isDown(1) then
    self._wait_mouse_release = false
  end
  if not self._wait_mouse_release then
    if self:inArea() then
      for _,obj in pairs(self:_buttonAreas()) do
        local mx,my = love.mouse.getPosition()
        obj.area.y = obj.area.y + 32 + self:_titleHeight() + self:_textHeight() + self:_guideHeight() + self:_imageHeight()
        obj.button.hover = self:_checkArea(mx,my,obj.area)
        if obj.button.callback and obj.button.hover and love.mouse.isDown(1) then
          obj.button.callback(self)
        end
      end
    end
  end
end

function window:addButton(text,callback)
  table.insert(self.buttons,{text=text,callback=callback})
  self:recalculateHeight()
end

function window:addGuide(text,icon)
  table.insert(self.guides,{text=text,icon=icon})
  self:recalculateHeight()
end

function window:_titleHeight()
  if self.title == nil then return 0 end
  local tfont = love.graphics.getFont()
  local width, wrappedtext = tfont:getWrap( self.title, self.w-64 )
  local height = tfont:getHeight()
  return height*#wrappedtext + self._spad
end

function window:_textHeight()
  if self.text == nil then return 0 end
  local tfont = love.graphics.getFont()
  local width, wrappedtext = tfont:getWrap( self.text, self.w-64 )
  local height = tfont:getHeight()
  return height*#wrappedtext + self._spad
end

function window:_guideHeight()
  return #self.guides > 0 and #self.guides*32+self._spad or 0
end

function window:_imageHeight()
  return self.image and self:_imageScale()*self.image:getHeight()+self._spad or 0
end

function window:_imageScale()
  return (self.w-64)/self.image:getWidth()
end

function window:_buttonHeight()
  return 32--+self._spad--last section to need pad
end

function window:_buttonAreas()
  local tfont = love.graphics.getFont()
  local areas = {}
  local button_offset = 0
  for ibutton,button in pairs(self.buttons) do
    local tx = self.x+32 + button_offset
    local ty = self.y
    local tw = tfont:getWidth(button.text)+16
    local th = 32
    table.insert(areas,{area={x=tx,y=ty,w=tw,h=th},button=button})
    button_offset = button_offset + tw + 8
  end
  return areas
end

function window:inArea(mx,my)
  if mx and my then
    -- yo momma
  else
    mx,my = love.mouse.getPosition()
  end
  return self:_checkArea(mx,my,self)
end

function window:_checkArea(x,y,obj)
  return x >= obj.x and x <= obj.x + obj.w and
    y >= obj.y and y <= obj.y + obj.h
end

function window:recalculateHeight()
  self.h = self:_recalculateHeight()
end

function window:_recalculateHeight()
  local h = 64 + self:_titleHeight() + self:_textHeight() + self:_guideHeight() + self:_imageHeight() + self:_buttonHeight()
  return h
end

return window
