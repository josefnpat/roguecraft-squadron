local matrixpanel = {}

matrixpanel.icon_bg = love.graphics.newImage("assets/hud/icon_bg.png")

function matrixpanel.new(init)
  init = init or {}
  local self = libs.drawable.new(init)

  self._drawbg = init.drawbg == nil and true or init.drawbg
  self._icon_bg = init.icon_bg or matrixpanel.icon_bg
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

  self.getHeight = matrixpanel.getHeight
  self.setIconPadding = matrixpanel.setIconPadding
  self.clearActions = matrixpanel.clearActions
  self.addAction = matrixpanel.addAction
  self.sort = matrixpanel.sort
  self.applyIconShortcutKeyTable = matrixpanel.applyIconShortcutKeyTable
  self.mouseInside = matrixpanel.mouseInside
  self.runHoverAction = matrixpanel.runHoverAction
  self.runAction = matrixpanel.runAction
  self.hasActions = matrixpanel.hasActions

  return self
end

function matrixpanel:mouseInside(x,y)
  x = x or love.mouse.getX()
  y = y or love.mouse.getY()
  return x >= self._x and y >= self._y and
    x <= self:getWidth() + self._x and
    y <= self:getHeight() + self._y
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
  return math.ceil(#self._actions/row)*iconsize+ipad*2
end

function matrixpanel:draw(bg,fg)
  if debug_hide_hud then
    return
  end
  if self._drawbg then
    tooltipbg(self._x,self._y,self._width,self:getHeight(),bg,fg)
  end
  for ai,action in pairs(self._actions) do
    local x,y,w,h = self:getIconArea(ai)
    local ix,iy = x + self._padding, y + self._padding
    if debug_mode then
      love.graphics.rectangle(action.hover and "fill" or "line",x,y,w,h)
    end
    if action.color then
      if type(action.color) == "function" then
        love.graphics.setColor(action.color(action.hover))
      else
        love.graphics.setColor(action.color)
      end
    end
    love.graphics.draw(self._icon_bg,ix,iy)
    if type(action) == "function" then
      love.graphics.draw(action.image(),ix,iy)
    else
      love.graphics.draw(action.image,ix,iy)
    end
    if self._hover == action and action.iconShortcutKey then
      love.graphics.setColor(255,255,255)
      dropshadow(action.iconShortcutKey,ix,iy)
    end
  end
  love.graphics.setColor(255,255,255)
  if self._hover then
    if type(self._hover_text) == "function" then
      self._hover_text()
    else
      tooltipf(self._hover_text,self._hover_x,self._hover_y,320,true)
    end
  end
  if debug_mode then
    debugrect(self._x,self._y,self._width,self:getHeight())
    for ai,action in pairs(self._actions) do
      local x,y,w,h = self:getIconArea(ai)
      debugrect(x,y,w,h)
    end
  end
end

function matrixpanel:update(dt)
  self:updateHint(dt)
  local found
  local mx,my = love.mouse.getPosition()
  for ai,action in pairs(self._actions) do
    action.hover = false
  end
  for ai,action in pairs(self._actions) do
    local x,y,w,h = self:getIconArea(ai)
    if mx >= x and mx <= x + w and my >= y and my <= y + h then
      found = action
      self._hover_x = x + self._iconSize+16
      self._hover_y = y + self._iconSize+16
      if type(action.text) == "function" then
        self._hover_text = action.text(self._hover_x,self._hover_y)
      else
        self._hover_text = tostring(action.text)
      end
      break
    end
  end
  self._hover = found
  if found then
    found.hover = true
  end
end

function matrixpanel:clearActions()
  self._actions = {}
end

function matrixpanel:addAction(image,callback,color,text,weight,iconShortcutKey)
  table.insert(self._actions,{
    image = image,
    callback = callback,
    color = color,
    text = text,
    weight = weight,
    iconShortcutKey = iconShortcutKey,
  })
end

function matrixpanel:sort(f)
  table.sort(self._actions,function(a,b)
    return a.weight < b.weight
  end)
end

function matrixpanel:applyIconShortcutKeyTable(t)
  for i,v in pairs(self._actions) do
    if self._actions[i] and t[i] then
      self._actions[i].iconShortcutKey = t[i]:upper()
    else
      self._actions[i].iconShortcutKey = nil
    end
  end
end

function matrixpanel:hasActions()
  return #self._actions > 0
end

function matrixpanel:runHoverAction()
  if self._hover then
    self._hover.callback()
  end
end

function matrixpanel:runAction(index)
  if self._actions[index] then
    self._actions[index].callback()
  end
end

return matrixpanel
