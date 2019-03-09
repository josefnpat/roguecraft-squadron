local mpwindow = {}

mpwindow.icons = {
  close=love.graphics.newImage("assets/hud/close.png"),
}

function mpwindow.new(init)
  init = init or {}
  local self = {}

  self.getWidth = mpwindow.getWidth
  self._width = init.width or 640
  self.getHeight = mpwindow.getHeight
  self._height = init.height or 360
  self.setActive = mpwindow.setActive
  self.isActive = mpwindow.isActive
  self.toggle = mpwindow.toggle
  self.setWindowTitle = mpwindow.setWindowTitle
  self.windowdraw = mpwindow.windowdraw
  self.windowupdate = mpwindow.windowupdate

  self._button_height = 32
  self._padding = 16
  self._window_title = "Window Title"

  self._closeButton = libs.button.new{
    width = 32,
    height = self._button_height,
    onClick = function()
      self:setActive(false)
    end,
    icon=mpwindow.icons.close,
  }

  return self
end

function mpwindow:getWidth()
  return self._width
end

function mpwindow:getHeight()
  return self._height
end

function mpwindow:setActive(val)
  self._active = val
end

function mpwindow:isActive(val)
  return self._active
end

function mpwindow:toggle()
  self:setActive(self:isActive())
end

function mpwindow:setWindowTitle(title)
  self._window_title = title
end


function mpwindow:windowdraw()

  local window = {
    x = (love.graphics.getWidth()-self:getWidth())/2,
    y = (love.graphics.getHeight()-self:getHeight())/2,
    width = self:getWidth(),
    height = self:getWidth(),
  }

  local x = window.x
  local y = window.y

  local window_title_height = fonts.window_title:getHeight()

  local content = {
    x=x+self._padding,
    y=y+window_title_height+self._padding*2,
    width=self:getWidth()-self._padding*2,
    height=self:getHeight()-window_title_height-self._closeButton:getHeight()-self._padding*4,
  }

  if self:isActive() then

    local old_color = {love.graphics.getColor()}
    love.graphics.setColor(0,0,0,191)
    love.graphics.rectangle("fill",0,0,love.graphics:getWidth(),love.graphics:getHeight())

    tooltipbg(x,y,self:getWidth(),self:getHeight())

    local padding = self._padding

    self._closeButton:setX(x+self:getWidth()-self._closeButton:getWidth()-padding)
    self._closeButton:setY(y+padding)
    self._closeButton:draw()

    local old_font = love.graphics.getFont()
    love.graphics.setFont(fonts.window_title)
    love.graphics.printf(self._window_title,x,y+padding,self:getWidth(),"center")
    love.graphics.setFont(old_font)

    love.graphics.setColor(255,255,255)

  end

  return window,content

end

function mpwindow:windowupdate(dt)
  if self:isActive() then
    self._closeButton:update(dt)
  end
end

return mpwindow
