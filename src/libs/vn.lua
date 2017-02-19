local vn = {}

function vn.new(init)
  local self = {}
  init = init or {}

  self._run = init.run or true
  self.getRun = vn.getRun
  self._frames = {}
  self.addFrame = vn.addFrame

  self._frame = 1

  self.draw = vn.draw
  self.next = vn.next

  return self
end

function vn:addFrame(image,name,text,audio)
  table.insert(self._frames,{image=image,name=name,text=text,audio=audio})
end

function vn:next()
  self._frame = self._frame + 1
  self._run = self._frames[self._frame] and true or false
end

function vn:draw()
  local cframe = self._frames[self._frame]
  if cframe then
    local orig_font = love.graphics.getFont()
    local padding = 16

    local vratio = 3/4
    local voffset = love.graphics.getHeight()*vratio
    local height = love.graphics.getHeight() - voffset

    local hratio = 1/4
    local hoffset = love.graphics.getWidth()*hratio
    local width = love.graphics.getWidth() - hoffset

    love.graphics.setColor(0,0,0,191)
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
    love.graphics.setColor(255,255,255)
    love.graphics.draw(cframe.image)
    love.graphics.setColor(0,0,0,191)
    love.graphics.rectangle("fill",padding,voffset+padding,
      love.graphics.getWidth()-padding*2,height-padding*2)
    love.graphics.setColor(255,255,255)
    love.graphics.setFont(fonts.vn_name)
    dropshadow(cframe.name,padding*2,voffset+padding*2)
    love.graphics.setFont(fonts.vn_text)
    dropshadowf(cframe.text,hoffset+padding*2,voffset+padding*2,
      width-padding*4,"left")
    love.graphics.setFont(orig_font)
  end
end

function vn:getRun()
  return self._run
end

function vn:run()
  self._run = true
end

return vn
