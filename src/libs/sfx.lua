local sfx = {}

function sfx.load()
  sfx._data = {}
  -- actions
  for _,action_pos in pairs({"start","end"}) do
    for _,action in pairs({"build","research","upgrade","work"}) do
      sfx.add("action."..action.."."..action_pos)
    end
  end
  -- cant afford
  for _,restype in pairs(libs.net.resourceTypes) do
    sfx.add("cant_afford."..restype)
  end
  sfx.add("cant_afford.multiple")
  -- cargo_full
  for _,restype in pairs(libs.net.resourceTypes) do
    sfx.add("cargo_full."..restype)
  end
  -- move
  for i = 1,4 do
    sfx.add("move","move."..i)
  end
  -- select
  for i = 1,6 do
    sfx.add("select","select."..i)
  end
  -- notif
  for i = 1,3 do
    sfx.add("notif.enemy","notif.enemy."..i)
  end
end

function sfx.add(name,fsloc)
  fsloc = fsloc or name
  sfx._data[name] = sfx._data[name] or {}
  table.insert(sfx._data[name],love.audio.newSource("assets/mp_vo/"..fsloc..".ogg","static"))
end

function sfx.get(name)
  return sfx._data[name][math.random(#sfx._data[name])]
end

function sfx.play(name,variation)
  local current_source
  for _,v in pairs(sfx._data[name]) do
    v:stop()
  end
  current_source = sfx._data[name][math.random(#sfx._data[name])]
  current_source:setVolume(settings:read("sfx_vol"))
  if variation then
    current_source:setPitch( (1-variation)+math.random()*variation*2 )
  else
    current_source:setPitch(1)
  end
  love.audio.play(current_source)
end

function sfx.loop(name,variation)
  local is_playing = false
  for _,source in pairs(sfx._data[name]) do
    if source:isPlaying( ) then
      is_playing = true
    end
  end
  if not is_playing then
    local current_source = sfx._data[name][math.random(#sfx._data[name])]
    current_source:setVolume(settings:read("sfx_vol"))
    if variation then
      current_source:setPitch( (1-variation)+math.random()*variation*2 )
    else
      current_source:setPitch(1)
    end
    love.audio.play(current_source)
  end
end

return sfx
