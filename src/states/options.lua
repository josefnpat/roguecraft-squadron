local state = {}

function state:init()

  self.menu = libs.menu.new{title="["..libs.i18n('options.title').."]"}

  self.menu:add(libs.i18n('options.fullscreen'),function()
    local fs = not settings:read("window_fullscreen")
    settings:write("window_fullscreen",fs)

    local msaa = settings:read("window_msaa")
    love.window.setMode(
      settings:read("window_width"),
      settings:read("window_height"),
      {fullscreen=fs,resizable=true,fullscreentype="desktop",msaa=msaa}
    )
  end)

  self.menu:add(
    function() 
      return libs.i18n('options.window_msaa',{window_msaa=settings:read("window_msaa")})
    end,
    function()
      local msaa = settings:read("window_msaa")
      msaa = msaa + 1
      if msaa > 4 then
        msaa = 0
      end
      settings:write("window_msaa",msaa)

      local fs = settings:read("window_fullscreen")
      love.window.setMode(
        settings:read("window_width"),
        settings:read("window_height"),
        {fullscreen=fs,resizable=true,fullscreentype="desktop",msaa=msaa}
      )
    end
  )

   self.menu:add(
    function()
      return libs.i18n('options.camera_speed',{camera_speed=settings:read("camera_speed")})
    end,
    function()
      local cam_speed = settings:read("camera_speed") + 0.25
      if cam_speed > 3 then
        cam_speed = 0.5
      end
      settings:write("camera_speed", cam_speed)
    end
  )

  self.menu:add(
    function()
      return libs.i18n('options.sfx_vol',{sfx_vol=math.floor(settings:read("sfx_vol")*100)})
    end,
    function()
      local vol = settings:read("sfx_vol") - 0.1
      if vol <= 0 then
        vol = 1
      end
      settings:write("sfx_vol",vol)
    end
  )

  self.menu:add(
    function()
      return libs.i18n('options.music_vol',{music_vol=math.floor(settings:read("music_vol")*100)})
    end,
    function()
      local vol = settings:read("music_vol") - 0.1
      if vol <= 0 then
        vol = 1
      end
      settings:write("music_vol",vol)
      states.menu.music.title:setVolume(vol)
      states.menu.music.game:setVolume(vol)
    end)

  self.menu:add(
    function()
      return libs.i18n('options.voiceover_vol',{voiceover_vol=math.floor(settings:read("voiceover_vol")*100)})
    end,
    function()
      local vol = settings:read("voiceover_vol") - 0.1
      if vol <= 0 then
        vol = 1
      end
      settings:write("voiceover_vol",vol)
    end)

  self.menu:add(
    function()
      return libs.i18n(
        'options.fow_quality',
        {fow_quality=(settings:read("fow_quality") == "img_canvas" and "High" or "Low")})
    end,
    function()
      local fowq = settings:read("fow_quality")
      settings:write("fow_quality", fowq == "img_canvas" and "circle_canvas" or "img_canvas")
    end)

  self.menu.bg_quality = {
    {value="none",string="None"},
    {value="low",string=libs.i18n('options.bg_quality.low')},
    {value="medium",string=libs.i18n('options.bg_quality.medium')},
    {value="high",string=libs.i18n('options.bg_quality.high')},
  }

  self.menu:add(
    function()
      local quality = settings:read("bg_quality")
      local quality_string = libs.i18n('options.bg_quality.pre')
      for _,v in pairs(self.menu.bg_quality) do
        if v.value == quality then
          return quality_string..v.string
        end
      end
      return quality_string..libs.i18n('options.bg_quality.unknown')
    end,
    function()
      local quality = settings:read("bg_quality")
      local first,use_next,next_quality
      for _,v in pairs(self.menu.bg_quality) do
        if first == nil then
          first = v
        end
        if use_next then
          use_next = nil
          next_quality = v
        elseif v.value == quality then
          use_next = true
        end
      end
      if use_next then
        next_quality = first
      end
      settings:write("bg_quality",next_quality.value)
      libs.stars:reload()
    end)

  self.menu:add(
    function()
      return libs.i18n('options.tutorial.pre')..": "..
        libs.i18n(settings:read("tutorial") == true and
          "options.tutorial.enabled" or
          "options.tutorial.disabled")
    end,
    function()
      local tut = not settings:read("tutorial")
      settings:write("tutorial",tut)
    end)

  self.menu:add(
    function()
      return libs.i18n('options.mouse_draw_mode.pre')..": "..
        libs.i18n(settings:read("mouse_draw_mode") == "software" and
          "options.mouse_draw_mode.software" or
          "options.mouse_draw_mode.hardware")
    end,
    function()
      local target_mode = settings:read("mouse_draw_mode") == "software" and "hardware" or "software"
      settings:write("mouse_draw_mode",target_mode)
      libs.cursor.mode(target_mode)
    end)

  self.menu:add(libs.i18n('options.back'),function()
    libs.hump.gamestate.switch(previousState)
  end)

end

function state:update(dt)
  self.menu:update(dt)
end

function state:draw()
  if previousState == states.pause then
    states.mission:draw()
    love.graphics.setColor(0,0,0,100)
    love.graphics.rectangle("fill",0,0,love.graphics:getWidth(),love.graphics:getHeight())
    love.graphics.setColor(255,255,255)
  else
    libs.stars:draw()
    libs.stars:drawPlanet()
  end
  self.menu:draw()
end

return state
