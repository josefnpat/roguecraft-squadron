local menu = {}

menu.change_sound = love.audio.newSource("assets/sfx/hover.ogg")
menu.callback_sound = love.audio.newSource("assets/sfx/select.ogg")

function menu.new(init)
  init = init or {}
  local self = {}

  self._title = init.title or ""
  self._entry_font = init.entry_font or fonts.menu
  self._title_font = init.title_font or fonts.title
  self._printf = dropshadowf or love.graphics.printf
  self._wait_on_release = false

  self.draw = menu.draw
  self.update = menu.update
  self.add = menu.add

  self.onChange = menu.onChange
  self.onCallback = menu.onCallback

  self.getEntryArea = menu.getEntryArea

  self._dt = 0
  self._data = {}

  return self
end

function menu:onChange()
  playSFX(menu.change_sound)
end

function menu:onCallback()
  playSFX(menu.callback_sound)
end

function menu:getEntryArea(i)
  local p = 4
  local x = love.graphics.getWidth()*11/16
  local w = love.graphics.getWidth()*2/8
  local h = 40
  local y = (love.graphics.getHeight()-(h+p)*#self._data)/2+(h+p)*(i-1)
  return x,y,w,h
end

function menu:draw()
  local old_font = love.graphics.getFont()
  local old_color = {love.graphics.getColor()}

  love.graphics.setFont(self._title_font)

  self._printf(self._title,
    0,
    (love.graphics.getHeight()-self._title_font:getHeight())/2,
    love.graphics.getWidth()*3/4,"center")

  love.graphics.setFont(self._entry_font)

  for i,v in pairs(self._data) do
    local x,y,w,h = self:getEntryArea(i)
    --love.graphics.rectangle(self._selected == i  and "fill" or "line",x,y,w,h)
    if self._selected == i then
      tooltipbg(x,y,w,h,{127,127,127,256*7/8},{255,255,255})
    else
      tooltipbg(x,y,w,h)
    end
    local font = love.graphics.getFont()
    local text_y_offset = (h-font:getHeight())/2
    local text = type(v.text) == "function" and v.text() or v.text
    self._printf(text,x,y+text_y_offset,w,"center")
  end

  love.graphics.setFont(old_font)
  love.graphics.setColor(old_color)
end

function menu:update(dt)
  self._dt = self._dt + dt
  local mx,my = love.mouse.getPosition()
  self._previous_selected = self._selected
  self._selected = nil
  for i,v in pairs(self._data) do
    local x,y,w,h = self:getEntryArea(i)
    if mx >= x and mx <= x+w and my >= y and my <= y+h then
      self._selected = i
      if self._previous_selected ~= self._selected then
        self:onChange()
      end
    end
  end
  if love.mouse.isDown(1) then
    if self._data[self._selected] and self._wait_on_release then
      self._data[self._selected].callback()
      self:onCallback()
    end
    self._wait_on_release = false
  else
    self._wait_on_release = true
  end

end

function menu:add(text,callback)
  table.insert(self._data,{
    text=text,
    callback=callback,
  })
end

return menu
