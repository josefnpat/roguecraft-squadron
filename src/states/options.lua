local state = {}

function state:init()

  self.menu = libs.menu.new{title="[OPTIONS]"}

  self.menu:add("Fullscreen",function()
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
      return "Multisample Anti-Aliasing: "..settings:read("window_msaa").."×" end,
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
    function() return "Camera Speed: "..settings:read("camera_speed").."×" end,
    function()
      local cam_speed = settings:read("camera_speed") + 0.25
      if cam_speed > 3 then
        cam_speed = 0.5
      end
      settings:write("camera_speed", cam_speed)
    end
  )

  self.menu:add(
    function() return "Sound Effect Volume: "..math.floor(settings:read("sfx_vol")*100).."%" end,
    function()
      local vol = settings:read("sfx_vol") - 0.1
      if vol <= 0 then
        vol = 1
      end
      settings:write("sfx_vol",vol)
    end
  )

  self.menu:add(
    function() return "Music Volume: "..math.floor(settings:read("music_vol")*100).."%" end,
    function()
      local vol = settings:read("music_vol") - 0.1
      if vol <= 0 then
        vol = 1
      end
      settings:write("music_vol",vol)
      states.menu.music:setVolume(vol)
    end)

  self.menu:add(
    function() return "Voiceover Volume: "..math.floor(settings:read("voiceover_vol")*100).."%" end,
    function()
      local vol = settings:read("voiceover_vol") - 0.1
      if vol <= 0 then
        vol = 1
      end
      settings:write("voiceover_vol",vol)
    end)

  self.menu:add(
    function() return "Fog of War Quality: "..
      (settings:read("fow_quality") == "img_canvas" and "High" or "Low")
    end,
    function()
      local fowq = settings:read("fow_quality")
      settings:write("fow_quality", fowq == "img_canvas" and "circle_canvas" or "img_canvas")
    end)

  self.menu.bg_quality = {
    {value="none",string="None"},
    {value="low",string="Low (1024×1024)"},
    {value="medium",string="Medium (2048×2048)"},
    {value="high",string="High (4096×4096)"},
  }

  self.menu:add(
    function()
      local quality = settings:read("bg_quality")
      local quality_string = "BG Quality: "
      for _,v in pairs(self.menu.bg_quality) do
        if v.value == quality then
          return quality_string..v.string
        end
      end
      return quality_string.."Unknown"
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
      return "Tutorial: "..
        (settings:read("tutorial") == true and "Enabled" or "Disabled")
    end,
    function()
      local tut = not settings:read("tutorial")
      settings:write("tutorial",tut)
    end)

  self.menu:add("Back",function()
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

  local vs_info = "Client GIT v"..git_count.." ["..git_hash.."]\n"
  if version_server then
    if version_server.count and version_server.hash then
      vs_info = vs_info .. "Server GIT v"..version_server.count.." ["..version_server.hash.."]\n"
    end
    if version_server.message then
      vs_info = vs_info .. "Server Message: ".. tostring(version_server.message).."\n"
    end
    if version_server.error then
      vs_info = vs_info .. "Server Error: ".. tostring(version_server.error).."\n"
    end
    if version_server.count > git_count then
      vs_info = vs_info .. "Your game is *not* up to date."
    elseif version_server.count < git_count then
      vs_info = vs_info .. "Your game is *ahead* of release."
    else -- ==
      vs_info = vs_info .. "Your game is up to date."
    end
  end
  dropshadowf(vs_info,
    32,32,love.graphics.getWidth()-64,"left")

end

return state
