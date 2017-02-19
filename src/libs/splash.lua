local splash = {}

function splash.new()
  local self={}
  self.draw=splash.draw
  self.update=splash.update
  self.done=splash.done
  self.stop=splash.stop
  self._image=nil --init
  self.getImage=splash.getImage
  self.setImage=splash.setImage
  self.setImages=splash.setImages
  self._sound=nil --init
  self.getSound=splash.getSound
  self.setSound=splash.setSound
  self._duration=5 --init
  self._startDuration=self._duration
  self.getDuration=splash.getDuration
  self.setDuration=splash.setDuration
  return self
end

function splash:draw()

  local x = 1-self._duration/self._startDuration
  local alpha = math.sin(x*math.pi)*255

  love.graphics.setColor(255,255,255,
    math.max(0,math.min(255,alpha))) --clamp

  local scale = self:getImage():getHeight() > love.graphics.getHeight() and 0.5 or 1

  love.graphics.draw(self:getImage(),
    love.graphics.getWidth()/2,
    love.graphics.getHeight()/2,
    0,scale,scale,
    self:getImage():getWidth()/2,
    self:getImage():getHeight()/2
  )

end

function splash:update(dt)
  self._duration = self._duration - dt
  if self:getSound() and not self:getSound():isPlaying() then
    self:getSound():play()
  end
end

function splash:done()
  if self._duration <= 0 then
    self:stop()
    return true
  end
end

function splash:stop()
  if self:getSound() then
    self:getSound():stop()
  end
  love.graphics.setColor(255,255,255)
  self._duration = 0
end

function splash:getImage()
	if not self.animated then
		return self._image 
	else
		return self._images[math.ceil((love.timer.getTime() * self.animationSpeed) % #self._images)]
	end
end

function splash:setImage(val)
  self.animated = false
  self._image=val
end

function splash:setImages(val,animationSpeed)
  self.animationSpeed = animationSpeed
  self.animated = true
  self._images=val
end

function splash:getSound()
  return self._sound
end

function splash:setSound(val)
  self._sound=val
end

function splash:getDuration()
  return self._duration
end

function splash:setDuration(val)
  self._startDuration=val
  self._duration=val
end

return splash
