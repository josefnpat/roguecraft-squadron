local state = {}

function state:init()

  self._maxFade = 10

  self.da = libs.dynamicaudio.new()
  self.da:addTrack("assets/dynamicaudio/AsteroidMining/1.ogg")
  self.da:addTrack("assets/dynamicaudio/AsteroidMining/2.ogg")
  self.da:addTrack("assets/dynamicaudio/AsteroidMining/3.ogg")
  self.da:addTrack("assets/dynamicaudio/AsteroidMining/4.ogg")

  self.sliders = {}

  local master = libs.slider.new{
    onChange=function(value)
      self.da:setMaster(value)
    end,
    text = function(self)
      return "Master Volume: " .. math.floor(self._value*100).."%"
    end,
  }
  master:setValue(self.da:getMaster())
  table.insert(self.sliders,master)

  local targetValue = libs.slider.new{
    onChange=function(value)
      self.da:setTargetValue(value)
    end,
    text = function(s)
      return "Target Track: " .. self.da:getTargetTrack()
    end,
  }
  targetValue:setValue(self.da:getTargetValue())
  table.insert(self.sliders,targetValue)

  for track_index,track in pairs(self.da._tracks) do

    -- fade in
    local fadeIn = libs.slider.new{
      onChange=function(value)
        self.da:setTrackFadeIn(track_index,value*self._maxFade)
      end,
      text = function(s)
        return "Track "..track_index.." Fade In: " .. (s._value*self._maxFade).."s"
      end,
    }
    fadeIn:setValue(self.da:getTrackFadeIn(track_index)/self._maxFade)
    table.insert(self.sliders,fadeIn)

    -- fade out
    local fadeOut = libs.slider.new{
      onChange=function(value)
        self.da:setTrackFadeOut(track_index,value*self._maxFade)
      end,
      text = function(s)
        return "Track "..track_index.." Fade Out: " .. (s._value*self._maxFade).."s"
      end,
    }
    fadeOut:setValue(self.da:getTrackFadeOut(track_index)/self._maxFade)
    table.insert(self.sliders,fadeOut)

  end

  self.buttons = {}

  table.insert(self.buttons,libs.button.new{
    text="Play",
    onClick=function()
      self.da:play()
    end
  })

  table.insert(self.buttons,libs.button.new{
    text="Pause",
    onClick=function()
      self.da:pause()
    end
  })

  table.insert(self.buttons,libs.button.new{
    text="Stop",
    onClick=function()
      self.da:stop()
    end
  })

end

function state:update(dt)
  self.da:update(dt)
  for _,slider in pairs(self.sliders) do
    slider:update(dt)
  end
  for _,button in pairs(self.buttons) do
    button:update(dt)
  end
end

function state:draw()

  libs.backgroundlib.draw()

  self.da:drawDebug()

  local cy = 32
  for slider_index,slider in pairs(self.sliders) do
    slider:setX(256)
    slider:setWidth(1000)
    slider:setY(cy)
    cy = cy + slider:getHeight() + 4
    slider:draw()
  end

  local cx = 256
  for _,button in pairs(self.buttons) do
    button:setX(cx)
    button:setY(cy+32)
    button:setWidth(64)
    cx = cx + button:getWidth() + 4
    button:draw(dt)
  end


end

return state
