local soundtrack = {}

function soundtrack.new(init)
  init = init or {}
  local self = {}

  self.update = soundtrack.update
  self.debugInfo = soundtrack.debugInfo

  self._isPlaying = false
  self.play = soundtrack.play
  self.stop = soundtrack.stop
  self.nextTrack = soundtrack.nextTrack
  self.randomTrack = soundtrack.randomTrack

  self.setIntensity = soundtrack.setIntensity

  self._volume = 0
  self.setVolume = soundtrack.setVolume

  self._data = {}
  self.addDynamicAudio = soundtrack.addDynamicAudio
  self.updateaDynamicAudio = soundtrack.updateaDynamicAudio

  return self
end

function soundtrack:update(dt)
  local data = self._data[self._currentDynamicAudio]
  if data then
    data.instance:update(dt)
    if data.updateTrackFade then
      data.updateTrackFade(data.instance)
    end
    if self._isPlaying then
      data.instance:play()
    else
      data.instance:stop()
    end
  else
    self._currentDynamicAudio = 1
  end
end

function soundtrack:debugInfo()
  local str = ""
  local data = self._data[self._currentDynamicAudio]
  if data then
    str = str .. data.instance:debugInfo()
  end
  return str
end

function soundtrack:play()
  self._isPlaying = true
end

function soundtrack:stop()
  self._isPlaying = false
end

function soundtrack:nextTrack()
  for _,data in pairs(self._data) do
    data.instance:setValue(0)
    data.instance:setTargetValue(0)
    data.instance:stop()
  end
  self._currentDynamicAudio = self._currentDynamicAudio + 1
end

function soundtrack:randomTrack()
  self._currentDynamicAudio = math.random(#self._data)
  -- self:nextTrack()
end

function soundtrack:setIntensity(intensity)
  if self._data[self._currentDynamicAudio] then
    self._data[self._currentDynamicAudio].instance:setTargetValue(intensity)
  end
end

function soundtrack:setVolume(vol)
  self._volume = vol
  for _,data in pairs(self._data) do
    data.instance:setMaster(vol)
  end
end

function soundtrack:addDynamicAudio(instance,updateTrackFade)
  if self._volume then
    instance:setMaster(self._volume)
  end
  table.insert(self._data,{instance=instance,updateTrackFade=updateTrackFade})
end

return soundtrack
