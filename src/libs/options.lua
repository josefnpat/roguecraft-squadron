local options = {}

local function updateWindowMode()
  love.window.setMode(
    settings:read("window_width"),
    settings:read("window_height"),
    {
      fullscreen=settings:read("window_fullscreen"),
      fullscreentype=settings:read("window_fullscreen_type"),
      resizable=true,
      msaa=settings:read("window_msaa"),
      display=settings:read('window_display'),
      vsync=settings:read('window_vsync'),
    }
  )
end
options.menu = libs.menu.new{title="["..libs.i18n('options.title').."]"}

options.menu:add(libs.i18n('options.fullscreen'),function()
  local fs = not settings:read("window_fullscreen")
  settings:write("window_fullscreen",fs)
  updateWindowMode()
end)

local modes = {}
for _,mode in pairs(love.window.getFullscreenModes()) do
  if mode.width >= 1280 and mode.height >= 720 then
    table.insert(modes,mode)
  end
end
table.sort(modes,function(a,b)
  if a.width == b.width then
    return a.height < b.height
  end
  return a.width < b.width
end)
currentMode = 1
for mode_index,mode in pairs(modes) do
  if mode.width == love.graphics.getWidth() and
    mode.height == love.graphics.getHeight() then
    currentMode = mode_index
  end
end

options.menu:addSlider(
  function(s)
    local mode = modes[math.floor(s:getRangeValue()+0.5)]
    if mode then
      return mode.width.."x"..mode.height
    else
      return love.graphics.getWidth().."x"..love.graphics.getHeight().." (custom)"
    end
  end,
  function(value,rangeValue,released)
    if released then
      local targetMode = math.floor(rangeValue+0.5)
      if modes[targetMode] then
        currentMode = targetMode
        local mode = modes[currentMode]
        love.window.setMode(mode.width,mode.height)
      end
    end
  end,
  currentMode,
  {1,#modes}
)

options.menu:add(
  function()
    return libs.i18n('options.fullscreen_type.pre')..": "..
      libs.i18n(settings:read("window_fullscreen_type") == "desktop" and
        "options.fullscreen_type.desktop" or
        "options.fullscreen_type.exclusive")
  end,
  function()
    local target_type = settings:read("window_fullscreen_type") == "desktop" and "exclusive" or "desktop"
    settings:write("window_fullscreen_type",target_type)
    updateWindowMode()
  end
)

options.menu:add(
  function()
    return libs.i18n('options.display')..": "..settings:read('window_display')
  end,
  function()
    local target_display = settings:read('window_display') + 1
    if target_display > love.window.getDisplayCount() then
      target_display = 1
    end
    settings:write('window_display',target_display)
    updateWindowMode()
  end
)

options.menu:add(
  function()
    return libs.i18n('options.vsync.pre')..": "..
      (settings:read('window_vsync') and libs.i18n('options.vsync.enabled') or libs.i18n('options.vsync.disabled'))
  end,
  function()
    settings:write('window_vsync',not settings:read('window_vsync'))
    updateWindowMode()
  end
)

options.menu:add(
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
    updateWindowMode()
  end
)

options.menu:addSlider(
  function()
    local camera_slow = libs.camera_edge.slow_camera and 1/10 or 1
    return libs.i18n('options.camera_speed',{
      camera_speed=math.floor(settings:read("camera_speed")*10+0.5)/10*camera_slow,
    })
  end,
  function(value,rangeValue)
    settings:write("camera_speed", rangeValue)
  end,
  settings:read("camera_speed"),{1,3}
)

options.menu:addSlider(
  function()
    return libs.i18n('options.sfx_vol',{sfx_vol=math.floor(settings:read("sfx_vol")*100)})
  end,
  function(value,rangeValue,released)
    settings:write("sfx_vol",value)
    if released then
      libs.sfx.play("widget.click")
    end
  end,
  settings:read("sfx_vol")
)

options.menu:addSlider(
  function()
    return libs.i18n('options.music_vol',{music_vol=math.floor(settings:read("music_vol")*100)})
  end,
  function(value,rangeValue)
    settings:write("music_vol",value)
    if states.menu.music then
      states.menu.music.title:setVolume(value)
    end
    if states.client.soundtrack then
      states.client.soundtrack:setVolume(settings:read("music_vol"))
    end
  end,
  settings:read("music_vol")
)

options.menu:addSlider(
  function()
    return libs.i18n('options.voiceover_vol',{voiceover_vol=math.floor(settings:read("voiceover_vol")*100)})
  end,
  function(value,rangeValue,released)
    settings:write("voiceover_vol",value)
    if released then
      libs.sfx.play("move")
    end
  end,
  settings:read("voiceover_vol")
)

options.menu:add(
  function()
    return libs.i18n(
      'options.fow_quality',
      {fow_quality=(settings:read("fow_quality") == "img_canvas" and "High" or "Low")})
  end,
  function()
    local fowq = settings:read("fow_quality")
    settings:write("fow_quality", fowq == "img_canvas" and "circle_canvas" or "img_canvas")
  end)

options.menu.bg_quality = {
  {value="none",string="None"},
  {value="low",string=libs.i18n('options.bg_quality.low')},
  {value="medium",string=libs.i18n('options.bg_quality.medium')},
  {value="high",string=libs.i18n('options.bg_quality.high')},
}

options.menu:add(
  function()
    local quality = settings:read("bg_quality")
    local quality_string = libs.i18n('options.bg_quality.pre')
    for _,v in pairs(options.menu.bg_quality) do
      if v.value == quality then
        return quality_string..v.string
      end
    end
    return quality_string..libs.i18n('options.bg_quality.unknown')
  end,
  function()
    local quality = settings:read("bg_quality")
    local first,use_next,next_quality
    for _,v in pairs(options.menu.bg_quality) do
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

options.menu:add(
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

options.menu:add(libs.i18n('options.back'),function()
  if libs.hump.gamestate.current() == states.client then
    states.client.menu = states.client.main_menu
  else -- assume menu
    libs.hump.gamestate.switch(states.menu)
  end
end)

return options
