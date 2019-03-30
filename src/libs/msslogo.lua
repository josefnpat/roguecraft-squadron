local msslogo = {}

function msslogo.new(init)
  init = init or {}
  local self = {}
  self.draw = msslogo.draw
  self.getHeight = msslogo.getHeight
  self.getWidth = msslogo.getWidth

  self._image = init.image or "logo.png"
  self._imageData = love.image.newImageData(self._image)
  self._size = init.size or 1
  if init.auto then
    self._size = math.floor(love.graphics.getWidth()/self._imageData:getWidth())
  end

  self._data = {}
  for y = self._imageData:getHeight()-1,0,-1 do
    for x = 0,self._imageData:getWidth()-1 do
      local r, g, b = self._imageData:getPixel(x, y)
      if r~=0 and g~=0 and b~=0 then
        table.insert(self._data,{
          color={r,g,b},x=x,y=y,
        })
      end
    end
  end

  self._data_rev = {}
  for y = 0,self._imageData:getHeight()-1 do
    for x = 0,self._imageData:getWidth()-1 do
      local r, g, b = self._imageData:getPixel(x, y)
      if r~=0 and g~=0 and b~=0 then
        table.insert(self._data_rev,{
          color={r,g,b},x=x,y=y,
        })
      end
    end
  end

  self._shader = libs.moonshine(libs.moonshine.effects.crt)
    .chain(libs.moonshine.effects.godsray)
    .chain(libs.moonshine.effects.filmgrain)

  self._percent = init.percent or function(n)
    local pct = math.min(1,math.max(n,0))
    if pct < 1/3 then
      return pct*3,false
    elseif pct < 2/3 then
      return 1,false
    else -- pct < 3/3 then
      return 1-(pct-2/3)*3,true
    end
  end

  return self
end

function msslogo:draw(n)
  local pct,rev = self._percent(n)
  local exposurepct = math.sin(1-pct)/math.pi
  self._shader.godsray.exposure = exposurepct
  local distpct = 0.5+pct/2
  self._shader.crt.distortionFactor = {distpct*1.06,distpct*1.065}
  local data = rev and self._data_rev or self._data
  self._shader(msslogo.draw_raw,self,data,pct)
end

function msslogo:draw_raw(data,pct)
  local x_offset = (love.graphics.getWidth()-self._imageData:getWidth()*self._size)/2
  local y_offset = (love.graphics.getHeight()-self._imageData:getHeight()*self._size)/2
  for i = 1,math.floor(pct*#data) do
    local v = data[i]
    if v then
      local x_random,y_random = 0,0
      x_random = math.random()*(1-pct/2)
      y_random = math.random()*(1-pct/2)
      love.graphics.setColor(v.color)
      love.graphics.rectangle("line",
        v.x*self._size+x_offset+x_random,
        v.y*self._size+y_offset+y_random,
        self._size*pct,self._size*pct
      )
    end
  end
end

function msslogo:getWidth()
  return self._size*self._imageData:getWidth()
end

function msslogo:getHeight()
  return self._size*self._imageData:getHeight()
end

return msslogo
