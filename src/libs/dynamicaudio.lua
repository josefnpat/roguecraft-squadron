local dynamicaudio = {}

function dynamicaudio.new(init)
  init = init or {}
  local self = {}

  self.update = dynamicaudio.update
  self.drawDebug = dynamicaudio.drawDebug
  self.debugInfo = dynamicaudio.debugInfo
  self.getTargetTrack = dynamicaudio.getTargetTrack

  self._master = init.master or 1
  self.setMaster = dynamicaudio.setMaster
  self.getMaster = dynamicaudio.getMaster

  self.setValue = dynamicaudio.setValue
  self.getValue = dynamicaudio.getValue
  self.setTargetValue = dynamicaudio.setTargetValue
  self.getTargetValue = dynamicaudio.getTargetValue

  self._tracks = {}
  self.addTrack = dynamicaudio.addTrack
  self.setTrackFadeIn = dynamicaudio.setTrackFadeIn
  self.getTrackFadeIn = dynamicaudio.getTrackFadeIn
  self.setTrackFadeOut = dynamicaudio.setTrackFadeOut
  self.getTrackFadeOut = dynamicaudio.getTrackFadeOut

  self._isPlaying = false
  self.play = dynamicaudio.play
  self.stop = dynamicaudio.stop
  self.pause = dynamicaudio.pause

  self:setValue(init.value or 0)
  self:setTargetValue(init.value or 0)

  return self
end

function dynamicaudio:update(dt)

  if self._isPlaying then
    local target_track = self:getTargetTrack()
    for current_track,track in pairs(self._tracks) do

      track.audio:setVolume(self._master*track.volume)

      if current_track == target_track then
        track.volume = math.min(1,track.volume + dt / track.fadeIn)
      else
        track.volume = math.max(0,track.volume - dt / track.fadeOut)
      end

    end
  end

end

function dynamicaudio:drawDebug()
  love.graphics.print(self:debugInfo(),64,64)
end

function dynamicaudio:debugInfo()
  local s = "Dynamicaudio Value: " .. self._value .. "\n"
  local s = "Target Track: " .. self:getTargetTrack() .. "\n"
  for track_index,track in pairs(self._tracks) do
    s = s .. "\tTrack "..track_index.." volume: " .. math.floor(track.volume*100) .. "%\n"
  end
  return s
end

function dynamicaudio:getTargetTrack()
  return math.min(#self._tracks,math.floor(self._targetValue*#self._tracks)+1)
end

function dynamicaudio:setMaster(val)
  assert(type(val)=="number")
  assert(val>=0 and val<=1)
  self._master = val
end

function dynamicaudio:getMaster()
  return self._master
end

function dynamicaudio:setValue(val)
  assert(type(val)=="number")
  assert(val>=0 and val<=1)
  self._value = val
end

function dynamicaudio:getValue(val)
  return self._value
end

function dynamicaudio:setTargetValue(val)
  assert(type(val)=="number")
  assert(val>=0 and val<=1)
  self._targetValue = val
end

function dynamicaudio:getTargetValue(val)
  return self._targetValue
end

function dynamicaudio:addTrack(audio_fn,fadeIn,fadeOut)
  local audio = love.audio.newSource(audio_fn)
  audio:setLooping(true)
  audio:setVolume(0)
  table.insert(self._tracks,{
    audio = audio,
    fadeIn = fadeIn or 1,
    fadeOut = fadeOut or 1,
    volume = 0,
  })
end

function dynamicaudio:setTrackFadeIn(track,fadeIn)
  assert(type(fadeIn)=="number")
  assert(fadeIn>=0)
  assert(self._tracks[track])
  self._tracks[track].fadeIn = fadeIn
end

function dynamicaudio:getTrackFadeIn(track)
  assert(self._tracks[track])
  return self._tracks[track].fadeIn
end

function dynamicaudio:setTrackFadeOut(track,fadeOut)
  assert(type(fadeOut)=="number")
  assert(fadeOut>=0)
  assert(self._tracks[track])
  self._tracks[track].fadeOut = fadeOut
end

function dynamicaudio:getTrackFadeOut(track)
  assert(self._tracks[track])
  return self._tracks[track].fadeOut
end

function dynamicaudio:play()
  for _,track in pairs(self._tracks) do
    track.audio:play()
  end
  self._isPlaying = true
end

function dynamicaudio:stop()
  for _,track in pairs(self._tracks) do
    track.audio:stop()
    track.volume = 0
  end
  self._isPlaying = false
end

function dynamicaudio:pause()
  for _,track in pairs(self._tracks) do
    track.audio:pause()
  end
  self._isPlaying  = false
end

return dynamicaudio
