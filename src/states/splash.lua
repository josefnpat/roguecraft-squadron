local splash = {}

function splash:enter()
  self._splashes = {}

  splashclass = libs.splash

  local lovelogo = splashclass.new()
  lovelogo:setImage(love.graphics.newImage("assets/splash/love.png"))
  local lovelogo_sound = love.sound.newSoundData("assets/splash/love.ogg")
  local lovelogo_audio = love.audio.newSource(lovelogo_sound)
  lovelogo:setSound(lovelogo_audio )
  lovelogo:setDuration( lovelogo_sound:getDuration() )
  table.insert(self._splashes,lovelogo)

  local mss = splashclass.new()
  mss:setImage(love.graphics.newImage("assets/splash/mss.png"))
  local mss_sound = love.sound.newSoundData("assets/splash/mss.ogg")
  local mss_audio = love.audio.newSource(mss_sound)
  mss:setSound( mss_audio )
  mss:setDuration( mss_sound:getDuration() )
  table.insert(self._splashes,mss)

  self._current = 1

end

function splash:leave()
  self._splashes = nil
  self._current = nil
end

function splash:draw()
  if self._splashes[self._current] then
    self._splashes[self._current]:draw()
  end
  if global_debug_mode then
    overscan.drawArea()
  end
end

function splash:update(dt)
  if self._splashes[self._current] == nil then
    libs.hump.gamestate.switch(states.menu)
  elseif self._splashes[self._current]:done() then
    self._current=self._current+1
  else
    self._splashes[self._current]:update(dt)
  end
end

function splash:keypressed()
  if self._splashes[self._current] then
    self._splashes[self._current]:stop()
  end
end

function splash:mousepressed()
  if self._splashes[self._current] then
    self._splashes[self._current]:stop()
  end
end

return splash
