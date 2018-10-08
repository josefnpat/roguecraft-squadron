local menu = {}

menu.change_sound = love.audio.newSource("assets/sfx/hover.ogg","static")
menu.callback_sound = love.audio.newSource("assets/sfx/select.ogg","static")

function menu.new(init)
  init = init or {}
  local self = {}

  self._title = init.title or ""
  self._entry_font = init.entry_font or fonts.menu
  self._title_font = init.title_font or fonts.title
  self._printf = dropshadowf or love.graphics.printf

  self.draw = menu.draw
  self.update = menu.update

  self.add = menu.addButton
  self.addButton = menu.addButton
  self.addSlider = menu.addSlider

  self.onChange = menu.onChange
  self.onCallback = menu.onCallback

  self.getEntryArea = menu.getEntryArea

  self._widgets = {}

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
  local y = (love.graphics.getHeight()-(h+p)*#self._widgets)/2+(h+p)*(i-1)
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

  for i,widget in pairs(self._widgets) do
    local x,y,w,h = self:getEntryArea(i)
    widget:setX(x)
    widget:setY(y)
    widget:setWidth(w)
    widget:setHeight(h)
    widget:draw()
  end

  love.graphics.setFont(old_font)
  love.graphics.setColor(old_color)
end

function menu:update(dt)
  for i,widget in pairs(self._widgets) do
    widget:update(dt)
  end

end

function menu:addButton(text,callback,disabled)
  table.insert(self._widgets,libs.button.new{
    text=text,
    onClick=callback,
    disabled=disabled,
  })
end

function menu:addSlider(text,callback,value,range)
  local slider = libs.slider.new{
    text=text,
    onChange=callback,
    range=range,
  }
  if range then
    slider:setRangeValue(value)
  else
    slider:setValue(value)
  end
  table.insert(self._widgets,slider)
end

return menu
