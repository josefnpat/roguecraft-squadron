local window = {}

window.icon_bg = love.graphics.newImage("assets/hud/icon_bg.png")

function window.new(init)
  init = init or {}
  local self = {}

  self.icon_size = init.icon_size or 32

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
  self.reset = window.reset

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

  self._spad = 8

  self.w = init.w or 320
  self.h = init.h or self:_recalculateHeight()
  self.x = init.x or love.graphics.getWidth()-64-self.w
  self.y = init.y or love.graphics.getHeight()-64-self.h

  self:reset()

  return self
end

function window:reset()
  self._dt = 0
  self._wait_mouse_release = true
end

function window:draw()

  local old_color = {love.graphics.getColor()}
  local old_font = love.graphics.getFont()
  tooltipbg(self.x,self.y,self.w,self.h,nil,self.color)

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
      love.graphics.draw(window.icon_bg,self.x+32,4+self.y+coffset+self.icon_size*(iguide-1))
      love.graphics.draw(guide.icon,self.x+32,4+self.y+coffset+self.icon_size*(iguide-1))
      dropshadow(guide.text,
        self.x+32+self.icon_size+8,
        self.y+coffset+self.icon_size*(iguide-1)+(32-tfont:getHeight())/2
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

      local btext = type(obj.button.text)=="function" and obj.button.text() or tostring(obj.button.text)

      dropshadow(btext,obj.area.x+8,obj.area.y+coffset+(obj.area.h-tfont:getHeight())/2)
    end
    coffset = coffset + self:_buttonHeight()
  end

  love.graphics.setFont(old_font)

end

function window:update(dt)
  self._dt = self._dt + dt

  self.ptext = string.sub(self.text,1,math.min(self._dt,1)*string.len(self.text))

  if not love.mouse.isDown(1) then
    self._wait_mouse_release = false
  end
  if not self._wait_mouse_release then
    if self:inArea() then
      for _,obj in pairs(self:_buttonAreas()) do
        local mx,my = love.mouse.getPosition()
        obj.area.y = 8 + obj.area.y + 32 + self:_titleHeight() + self:_textHeight() + self:_guideHeight() + self:_imageHeight()
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
  return #self.guides > 0 and #self.guides*self.icon_size+self._spad or 0
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

    local btext = type(button.text)=="function" and button.text() or tostring(button.text)

    local tx = self.x+32 + button_offset
    local ty = self.y
    local tw = tfont:getWidth(btext)+16
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
