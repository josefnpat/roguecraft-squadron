local chat = {}

function chat.new(init)
  init = init or {}
  local self = {}

  self._x = init.x or 0
  self._y = init.y or 0
  self._width = init.width or 320
  self._height = init.height or 240
  self._active = false
  self._buffer = ""
  self._data = {}
  self._padding = 4
  self._dt = 0
  self._height_small = init.height or 240
  self._height_large = init.height_large or 640

  self.draw = chat.draw
  self.update = chat.update
  self.setActive = chat.setActive
  self.getActive = chat.getActive
  self.getBuffer = chat.getBuffer
  self.setBuffer = chat.setBuffer
  self.mouseInside = chat.mouseInside
  self.addData = chat.addData
  self.toggleHeight = chat.toggleHeight
  self.smallHeight = chat.smallHeight
  self.largeHeight = chat.largeHeight

  self.setX = chat.setX
  self.getX = chat.getX
  self.setY = chat.setY
  self.getY = chat.getY
  self.setWidth = chat.setWidth
  self.getWidth = chat.getWidth
  self.setHeight = chat.setHeight
  self.getHeight = chat.getHeight

  return self
end

function chat:draw()
  if debug_hide_hud then return end
  if game_singleplayer then return end
  love.graphics.setScissor(self._x,self._y,self._width,self._height)
  local font = love.graphics.getFont()
  local offset = font:getHeight()+self._padding*2

  local text,fg,bg_chat,bg_buffer
  if self._active then
    local adjw,sublines = font:getWrap(self._buffer,self._width-self._padding*2)
    text = (sublines[#sublines] or "") .. (self._dt%1>0.5 and "_" or "")
    fg = {0,255,255}
    bg_chat = {31,63,63,127}
    bg_buffer = nil
    buffer_color = {255,255,255}
  else
    text = libs.i18n('chat.default')
    fg = {0,127,127,127}
    bg_chat = {0,0,0,0}
    bg_buffer = {0,0,0,0}
    buffer_color = {0,255,255,127}
  end

  tooltipbg(self._x,self._y,self._width,self._height-offset,bg_chat,fg)
  tooltipbg(self._x,self._y+self._height-offset,self._width,offset,bg_buffer,fg)
  love.graphics.setColor(buffer_color)
  love.graphics.printf(text,
    self._x+self._padding,self._y+self._height-offset+self._padding,
    self._width-self._padding*2,self._active and "left" or "center")
  for _,data in pairs(self._data) do
    local line = data.user_name..": "..data.text
    local adjw,sublines = font:getWrap(line,self._width-self._padding*2)
    local h = font:getHeight(line) * #sublines
    offset = offset + h + self._padding*2
    local text_x = self._x+self._padding
    local text_y = self._y+self._height-offset+self._padding
    local text_w = self._width-self._padding*2
    local text_align = "left"
    love.graphics.setColor(0,0,0,127)
    for _,x in pairs({-1,1}) do
      for _,y in pairs({-1,1}) do
        love.graphics.printf(line,text_x+x,text_y+y,text_w,text_align)
      end
    end
    love.graphics.setColor(data.selected_color)
    love.graphics.printf(line,text_x,text_y,text_w,text_align)
    if offset > self._height then
      break
    end
  end
  love.graphics.setColor(255,255,255)
  love.graphics.setScissor()
end

function chat:update(dt)
  if game_singleplayer then return end
  self._dt = self._dt + dt
end

function chat:setActive(val)
  self._active = val == true
end

function chat:getActive()
  if game_singleplayer then return false end
  return self._active
end

function chat:getBuffer()
  return self._buffer
end

function chat:setBuffer(buffer)
  self._buffer = buffer
end

function chat:mouseInside()
  if game_singleplayer then return false end
  if self._active then return true end
  local mx,my = love.mouse.getPosition()
  local font = love.graphics.getFont()
  local offset = font:getHeight()+self._padding*2
  local x,y,w,h = self._x,self._y+self._height-offset,self._width,offset
  return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function chat:addData(user_id,text,user_name)
  local user_data = libs.net.getUser(user_id)
  table.insert(self._data,1,{
    user_name=user_name or user_data.name,
    text=text,
    color=user_data.color,
    selected_color=user_data.selected_color,
  })
end

function chat:toggleHeight()
  self._height = (self._height == self._height_small) and
    self._height_large or self._height_small
end

function chat:smallHeight()
  self._height = self._height_small
end

function chat:largeHeight()
  self._height = self._height_large
end

function chat:setX(val)
  self._x = val
end

function chat:getX()
  return self._x
end

function chat:setY(val)
  self._y = val
end

function chat:getY()
  return self._y
end

function chat:setWidth(val)
  self._width = val
end

function chat:getWidth()
  return self._width
end

function chat:setHeight(val)
  self._height = val
end

function chat:getHeight()
  return self._height
end

return chat
