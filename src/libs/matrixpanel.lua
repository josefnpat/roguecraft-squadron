local matrixpanel = {}

matrixpanel.icon_bg = love.graphics.newImage("assets/hud/icon_bg.png")

function matrixpanel.new(init)
  init = init or {}
  local self = {}

  self._x = init.x or 32
  self._y = init.y or 32
  self._width = init.width or 256
  self._padding = init.padding or 4
  self._actions = {}
  self._iconSize = init.iconSize or 32

  self.getIconArea = matrixpanel.getIconArea
  self.getIconData = matrixpanel.getIconData
  self.draw = matrixpanel.draw
  self.update = matrixpanel.update

  self.setX = matrixpanel.setX
  self.setY = matrixpanel.setY
  self.setWidth = matrixpanel.setWidth
  self.getHeight = matrixpanel.getHeight
  self.setIconPadding = matrixpanel.setIconPadding
  self.addAction = matrixpanel.addAction
  self.mouseInArea = matrixpanel.mouseInArea

  return self
end

function matrixpanel:getIconArea(i)
  -- todo: this is beyond lazy -- but hell, who needs sleep?
  local row,iconsize,ipad = self:getIconData()
  local dx,dy = 0,1
  for ai,action in pairs(self._actions) do
    dx = dx + 1
    if dx > row then
      dx = 1
      dy = dy + 1
    end
    if ai == i then
      local x = ipad + self._x + iconsize*(dx-1)
      local y = ipad + self._y + iconsize*(dy-1)
      return x,y,iconsize,iconsize
    end
  end
end

function matrixpanel:getIconData()
  local iconsize = self._iconSize + self._padding*2
  local row = math.floor(self._width/iconsize)
  local ipad = (self._width - iconsize*row)/2
  return row,iconsize,ipad
end

function matrixpanel:getHeight()
  local row,iconsize,ipad = self:getIconData()
  return math.floor(#self._actions/row+1)*iconsize+ipad*2
end

function matrixpanel:draw()

  tooltipbg(self._x,self._y,self._width,self:getHeight())
  for ai,action in pairs(self._actions) do
    local x,y,w,h = self:getIconArea(ai)
    local ix,iy = x + self._padding, y + self._padding
    if debug_mode then
      love.graphics.rectangle(action.hover and "fill" or "line",x,y,w,h)
    end
    love.graphics.draw(matrixpanel.icon_bg,ix,iy)
    love.graphics.draw(action.image,ix,iy)
  end
end

function matrixpanel:update(dt)
  local found
  local mx,my = love.mouse.getPosition()
  for ai,action in pairs(self._actions) do
    action.hover = false
  end
  for ai,action in pairs(self._actions) do
    local x,y,w,h = self:getIconArea(ai)
    if mx >= x and mx <= x + w and my >= y and my <= y + h then
      found = action
      break
    end
  end
  self._hover = found
  if found then
    found.hover = true
  end
end

function matrixpanel:addAction(image)
  table.insert(self._actions,{
    image = image,
  })
end

return matrixpanel
