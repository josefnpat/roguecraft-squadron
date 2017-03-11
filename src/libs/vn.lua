local vn = {}

function vn.new(init)
  local self = {}
  init = init or {}

  self._run = init.run or true
  self.getRun = vn.getRun
  self.update = vn.update
  self._frames = {}
  self.addFrame = vn.addFrame

  self._frame = 1

  self.draw = vn.draw
  self.next = vn.next
  self.play = vn.play
  self.stop = vn.stop

  self.overlay_animation_limit = 1
  self.overlay_animation_timer = 0
  self.overlay_current_frame = 1
  self.overlay_next_frame = 1

  self._init = true

  return self
end

function vn:addFrame(image,overlay,name,text,audio)
  table.insert(self._frames,{image=image,overlay=overlay,name=name,text=text,audio=audio})
end

function vn:stop()
  local cframe = self._frames[self._frame]
  if cframe then
    if cframe.audio then
      cframe.audio:stop()
    end
  end
  self._run = false
end

function vn:update(dt)
  local cframe = self._frames[self._frame]
  self.overlay_animation_timer = self.overlay_animation_timer + dt
  if cframe.overlay and self.overlay_animation_timer > self.overlay_animation_limit then
    self.overlay_current_frame = self.overlay_current_frame + 1
    self.overlay_animation_timer = 0
    if self.overlay_current_frame > #cframe.overlay then
      self.overlay_current_frame = 1
    end
    self.overlay_next_frame = self.overlay_current_frame + 1
    if self.overlay_next_frame > #cframe.overlay then
      self.overlay_next_frame = 1
    end
  end
end

function vn:play()
  local cframe = self._frames[self._frame]
  if cframe then
    if cframe.audio then
      cframe.audio:play()
    end
  end
end

function vn:next()
  self:stop()
  self._frame = self._frame + 1
  self._run = self._frames[self._frame] and true or false
  self:play()
end

function vn:draw()
  local cframe = self._frames[self._frame]
  if cframe then

    if self._init then
      self._init = false
      self:play()
    end

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

    if cframe.image then
      local coffx,coffy = hoffset+padding*2,love.graphics.getHeight()-cframe.image:getHeight()-padding*2
      love.graphics.draw(cframe.image,coffx,coffy)
      if cframe.overlay and cframe.overlay[self.overlay_current_frame] and cframe.overlay[self.overlay_next_frame] then
        love.graphics.setColor(255,255,255,(self.overlay_animation_timer/self.overlay_animation_limit) * 255)
        love.graphics.draw(cframe.overlay[self.overlay_current_frame],coffx,coffy)
        love.graphics.setColor(255,255,255,(1-(self.overlay_animation_timer/self.overlay_animation_limit)) * 255)
        love.graphics.draw(cframe.overlay[self.overlay_next_frame],coffx,coffy)
      end

    end
    love.graphics.setColor(0,0,0,191)
    love.graphics.rectangle("fill",padding,voffset+padding,
    love.graphics.getWidth()-padding*2,height-padding*2)
    love.graphics.setColor(255,255,255)
    love.graphics.setFont(fonts.vn_name)
    dropshadow(cframe.name,padding*2,voffset+padding*2)
    love.graphics.setFont(fonts.vn_text)
    dropshadowf(cframe.text,hoffset+padding*2,voffset+padding*2,width-padding*4,"left")
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
