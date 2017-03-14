local state = {}

function state:init()

  self.menu = libs.menu.new{title="[OPTIONS]"}

  self.menu:add("Fullscreen",function()
    local fs = not settings:read("window_fullscreen",false)
    settings:write("window_fullscreen",fs)
    love.window.setMode(
      settings:read("window_width",1280),
      settings:read("window_height",720),
      {fullscreen=fs,resizable=true,fullscreentype="desktop"}
    )
  end)

  self.menu:add(
    function() return "Sound Effect Volume: "..math.floor(settings:read("sfx_vol",1)*100).."%" end,
    function()
      local vol = settings:read("sfx_vol",1) - 0.1
      if vol <= 0 then
        vol = 1
      end
      settings:write("sfx_vol",vol)
    end)

  self.menu:add(
    function() return "Music Volume: "..math.floor(settings:read("music_vol",1)*100).."%" end,
    function()
      local vol = settings:read("music_vol",1) - 0.1
      if vol <= 0 then
        vol = 1
      end
      settings:write("music_vol",vol)
      states.menu.music:setVolume(vol)
    end)

  self.menu:add(
    function() return "Fog of War Quality: "..
      (settings:read("fow_quality","img_canvas") == "img_canvas" and "High" or "Low")
    end,
    function()
      local fowq = settings:read("fow_quality","img_canvas")
      settings:write("fow_quality", fowq == "img_canvas" and "circle_canvas" or "img_canvas")
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
  end
  self.menu:draw()
end

return state
